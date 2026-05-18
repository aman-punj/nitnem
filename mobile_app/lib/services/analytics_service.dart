import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logPrayerOpened({
    required String prayerId,
    required String prayerName,
  }) =>
      _analytics.logEvent(name: 'prayer_opened', parameters: {
        'prayer_id': prayerId,
        'prayer_name': prayerName,
      });

  Future<void> logReminderToggled({
    required String type,
    required bool enabled,
  }) =>
      _analytics.logEvent(name: 'reminder_toggled', parameters: {
        'type': type,
        'enabled': enabled,
      });

  Future<void> logNotificationTapped() =>
      _analytics.logEvent(name: 'notification_tapped');

  Future<void> logCustomReminderAdded() =>
      _analytics.logEvent(name: 'custom_reminder_added');
}
