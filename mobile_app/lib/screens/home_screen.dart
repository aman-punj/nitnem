import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/settings_screen.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/share_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
  }

  Future<void> _requestNotificationPermission() async {
    final notificationService = Get.find<NotificationService>();

    try {
      await notificationService.requestPermissions();
      final enabled = await notificationService.areNotificationsEnabled();
      if (!enabled && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notifications Disabled'),
            content: const Text(
                'Media controls need notification permission. Please enable notifications for Bani Sagar in Android Settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notifications Disabled'),
            content: const Text(
                'To get updates and background controls, please enable notifications in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: SacredDsAppBar(
        title: 'Bani Sagar',
        appBarStyle: TextStyle(
          fontSize: 24,
          color: c.primary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: c.primary),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: const ListingScreen(),
    );
  }

  void onShareApp() {
    Get.find<ShareService>().shareApp(context);
  }
}
