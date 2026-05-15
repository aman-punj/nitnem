import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload == 'audio_playback') {
          // Handle notification tap if needed
        }

        // Handle actions
        if (details.actionId == 'pause_action') {
          // We need a way to communicate back to the controller
          // Since we are using GetX, we can find the controller if it's active
          try {
            // This is a bit tricky since PrayerController uses tags.
            // For now, let's assume we might need a global event or similar if we want to support multiple tags.
            // But usually only one prayer is playing.
          } catch (e) {
            // Error handling notification action
          }
        }
      },
    );

    return this;
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  // Categories defined for future management
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Media playback notification
  Future<void> showMediaNotification({
    required String title,
    required bool isPlaying,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'media_channel_id',
      'Media Playback',
      channelDescription: 'Media playback notifications',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
      ongoing: true,
      // Keep it pinned if it's playing
      onlyAlertOnce: true,
      icon: 'ic_notification', // Ensure this matches what we added
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      100, // Fixed ID for the media notification
      title,
      isPlaying ? 'Playing' : 'Paused',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelMediaNotification() async {
    await _notificationsPlugin.cancel(100);
  }
}