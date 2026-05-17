import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class NotificationSettingsController extends GetxService {
  // SharedPrefs keys
  static const _kMorningEnabled = 'notif_morning_enabled';
  static const _kMorningTime = 'notif_morning_time';
  static const _kMorningMsg = 'notif_morning_msg';
  static const _kMorningUserSet = 'notif_morning_user_set';
  static const _kEveningEnabled = 'notif_evening_enabled';
  static const _kEveningTime = 'notif_evening_time';
  static const _kEveningMsg = 'notif_evening_msg';
  static const _kEveningUserSet = 'notif_evening_user_set';
  static const _kKumnaamaEnabled = 'notif_kumnama_enabled';

  static const _fcmTopic = 'kumnama';

  // Reactive state
  final morningEnabled = true.obs;
  final morningTime = const TimeOfDay(hour: 6, minute: 0).obs;
  final morningUserSetTime = false.obs;
  final eveningEnabled = true.obs;
  final eveningTime = const TimeOfDay(hour: 18, minute: 30).obs;
  final eveningUserSetTime = false.obs;
  final kumnaamaEnabled = true.obs;

  // Server-controlled message text (not user-editable)
  String _morningMsg = 'Time for your morning Nitnem';
  String _eveningMsg = 'Time for your evening Nitnem';

  NotificationService get _svc => Get.find<NotificationService>();

  Future<NotificationSettingsController> init() async {
    _loadFromPrefs();
    await _syncFromFirestore();
    await _applyAllSchedules();
    return this;
  }

  void _loadFromPrefs() {
    final prefs = SharedPrefsService.instance;
    morningEnabled.value =
        SharedPrefsService.getBool(_kMorningEnabled, defaultValue: true);
    eveningEnabled.value =
        SharedPrefsService.getBool(_kEveningEnabled, defaultValue: true);
    kumnaamaEnabled.value =
        SharedPrefsService.getBool(_kKumnaamaEnabled, defaultValue: true);
    morningUserSetTime.value =
        SharedPrefsService.getBool(_kMorningUserSet, defaultValue: false);
    eveningUserSetTime.value =
        SharedPrefsService.getBool(_kEveningUserSet, defaultValue: false);
    morningTime.value = _parseTime(prefs.getString(_kMorningTime) ?? '06:00');
    eveningTime.value = _parseTime(prefs.getString(_kEveningTime) ?? '18:30');
    _morningMsg =
        prefs.getString(_kMorningMsg) ?? 'Time for your morning Nitnem';
    _eveningMsg =
        prefs.getString(_kEveningMsg) ?? 'Time for your evening Nitnem';
  }

  // Syncs server-defined defaults. Message text always updates.
  // Notification times only update if the user has not customised them.
  Future<void> _syncFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('notifications')
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final prefs = SharedPrefsService.instance;

      if (data['morning_message'] is String) {
        _morningMsg = data['morning_message'] as String;
        await prefs.setString(_kMorningMsg, _morningMsg);
      }
      if (data['evening_message'] is String) {
        _eveningMsg = data['evening_message'] as String;
        await prefs.setString(_kEveningMsg, _eveningMsg);
      }
      if (!morningUserSetTime.value && data['morning_time'] is String) {
        morningTime.value = _parseTime(data['morning_time'] as String);
        await prefs.setString(_kMorningTime, data['morning_time'] as String);
      }
      if (!eveningUserSetTime.value && data['evening_time'] is String) {
        eveningTime.value = _parseTime(data['evening_time'] as String);
        await prefs.setString(_kEveningTime, data['evening_time'] as String);
      }
    } catch (e) {
      debugPrint('Notification settings Firestore sync failed: $e');
    }
  }

  // ── Public setters ────────────────────────────────────────────────────────

  Future<void> setMorningEnabled(bool val) async {
    morningEnabled.value = val;
    await SharedPrefsService.setBool(_kMorningEnabled, val);
    await _applyMorning();
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    morningTime.value = time;
    morningUserSetTime.value = true;
    await SharedPrefsService.instance.setString(
        _kMorningTime, _formatTime(time));
    await SharedPrefsService.setBool(_kMorningUserSet, true);
    await _applyMorning();
  }

  Future<void> setEveningEnabled(bool val) async {
    eveningEnabled.value = val;
    await SharedPrefsService.setBool(_kEveningEnabled, val);
    await _applyEvening();
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    eveningTime.value = time;
    eveningUserSetTime.value = true;
    await SharedPrefsService.instance.setString(
        _kEveningTime, _formatTime(time));
    await SharedPrefsService.setBool(_kEveningUserSet, true);
    await _applyEvening();
  }

  Future<void> setKumnaamaEnabled(bool val) async {
    kumnaamaEnabled.value = val;
    await SharedPrefsService.setBool(_kKumnaamaEnabled, val);
    await _applyKumnama();
  }

  // ── Schedule helpers ──────────────────────────────────────────────────────

  Future<void> _applyAllSchedules() async {
    await _applyMorning();
    await _applyEvening();
    await _applyKumnama();
  }

  Future<void> _applyMorning() async {
    if (morningEnabled.value) {
      await _svc.scheduleDailyNotification(
        id: 0,
        title: 'Morning Nitnem',
        body: _morningMsg,
        hour: morningTime.value.hour,
        minute: morningTime.value.minute,
      );
    } else {
      await _svc.cancelNotification(0);
    }
  }

  Future<void> _applyEvening() async {
    if (eveningEnabled.value) {
      await _svc.scheduleDailyNotification(
        id: 1,
        title: 'Evening Nitnem',
        body: _eveningMsg,
        hour: eveningTime.value.hour,
        minute: eveningTime.value.minute,
      );
    } else {
      await _svc.cancelNotification(1);
    }
  }

  Future<void> _applyKumnama() async {
    if (kumnaamaEnabled.value) {
      await _svc.subscribeToTopic(_fcmTopic);
    } else {
      await _svc.unsubscribeFromTopic(_fcmTopic);
    }
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 6, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String formatTimeLabel(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
