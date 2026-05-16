import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool morningReminder = SharedPrefsService.getBool('morning_reminder', defaultValue: true);
  bool eveningReminder = SharedPrefsService.getBool('evening_reminder', defaultValue: true);
  bool hukamnama = SharedPrefsService.getBool('hukamnama_reminder', defaultValue: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: const SacredDsAppBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Morning Nitnem Reminder', style: TextStyle(color: SacredColors.textPrimary)),
            value: morningReminder,
            onChanged: (val) {
              setState(() => morningReminder = val);
              SharedPrefsService.setBool('morning_reminder', val);
            },
            activeColor: SacredColors.primaryAccent,
          ),
          SwitchListTile(
            title: const Text('Evening Nitnem Reminder', style: TextStyle(color: SacredColors.textPrimary)),
            value: eveningReminder,
            onChanged: (val) {
              setState(() => eveningReminder = val);
              SharedPrefsService.setBool('evening_reminder', val);
            },
            activeColor: SacredColors.primaryAccent,
          ),
          SwitchListTile(
            title: const Text('Daily Hukamnama', style: TextStyle(color: SacredColors.textPrimary)),
            value: hukamnama,
            onChanged: (val) {
              setState(() => hukamnama = val);
              SharedPrefsService.setBool('hukamnama_reminder', val);
            },
            activeColor: SacredColors.primaryAccent,
          ),
        ],
      ),
    );
  }
}
