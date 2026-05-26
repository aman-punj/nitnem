import 'package:audio_session/audio_session.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

/// Required by flutter_local_notifications v18 so the plugin can route
/// notification interaction events when the app is terminated.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('Notification tap background: id=${response.id} payload=${response.payload}');
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Set by HomeScreen to handle hukamnama notification taps.
  void Function()? onHukamnamaTap;

  static const _channelId = 'nitnem_daily';
  static const _channelName = 'Daily Nitnem Reminders';

  // Some Android versions return the deprecated IANA name; map to the canonical one.
  static const _tzAliases = {'Asia/Calcutta': 'Asia/Kolkata'};

  Future<NotificationService> init() async {
    tz.initializeTimeZones();
    final rawTz = await FlutterTimezone.getLocalTimezone();
    final localTz = _tzAliases[rawTz] ?? rawTz;
    tz.setLocalLocation(tz.getLocation(localTz));

    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'hukamnama') {
          onHukamnamaTap?.call();
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Show local notification when FCM arrives in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Log token so FCM delivery can be verified during development.
    _fcm.getToken().then((token) => debugPrint('FCM token: $token'));

    return this;
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final isHukamnama = message.data['type'] == 'hukamnama';
    showNotification(
      id: message.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: isHukamnama ? 'hukamnama' : null,
    );
  }

  // ── Permissions ──────────────────────────────────────────────────────────

  /// Requests basic notification permissions (FCM + POST_NOTIFICATIONS + SCHEDULE_EXACT_ALARM).
  /// Includes exact alarm since scheduled local notifications require it on Android 12+.
  Future<void> requestBasicPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  /// Returns true when the user has permanently denied notification permission
  /// (i.e. "Don't ask again" on Android, or denied twice on iOS).
  /// In this state only [openAppSettings] can re-enable notifications.
  Future<bool> isNotificationPermissionPermanentlyDenied() async {
    final status = await ph.Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  Future<bool> canScheduleExact() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? false;
  }

  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? false;
  }

  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  Future<void> openAlarmSettings() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  // ── FCM topics ───────────────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('FCM subscribed to "$topic"');
    } catch (e) {
      debugPrint('FCM subscribe "$topic" error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('FCM unsubscribed from "$topic"');
    } catch (e) {
      debugPrint('FCM unsubscribe "$topic" error: $e');
    }
  }

  // ── Local notifications ──────────────────────────────────────────────────

  static const _largeIcon = DrawableResourceAndroidBitmap('ic_notification_large');

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(id);
    final useExact = await canScheduleExact();
    final scheduleMode = useExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final nextTime = _nextInstanceOfTime(hour, minute);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        nextTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            largeIcon: _largeIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled notification: id=$id, $title at ${nextTime.toString()}, '
          'exact=$useExact, mode=$scheduleMode');
    } catch (e) {
      debugPrint('ERROR scheduling notification id=$id: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          largeIcon: _largeIcon,
        ),
      ),
      payload: payload,
    );
  }

  /// Returns a list of IDs of all pending scheduled notifications.
  /// Useful for debugging whether notifications are actually scheduled.
  Future<List<int>> getPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((n) => n.id).toList();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
