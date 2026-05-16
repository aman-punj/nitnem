import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/feedback_screen.dart';
import 'package:nitnem/screens/manage_notifications_screen.dart';
import 'package:nitnem/screens/settings_screen.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/share_service.dart';
import 'package:nitnem/models/drawer_item.dart';

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
    return Scaffold(
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: SacredDsAppBar(
        title: 'Bani Sagar',
        appBarStyle: const TextStyle(
          fontSize: 24,
          color: SacredColors.primary
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: SacredColors.primary),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: const ListingScreen(),
    );
  }

  void _onDrawerItemSelect(DrawerMenuItem item) {
    Get.back();
    switch (item) {
      case DrawerMenuItem.notifications:
        Get.to(() => const ManageNotificationsScreen());
        break;
      case DrawerMenuItem.language:
        break;
      case DrawerMenuItem.share:
        onShareApp();
        break;
      case DrawerMenuItem.feedback:
        Get.to(() => FeedbackScreen());
        break;
      case DrawerMenuItem.theme:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DrawerMenuItem.typography:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DrawerMenuItem.clear_cache:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DrawerMenuItem.keep_awake:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DrawerMenuItem.faq:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DrawerMenuItem.privacy_policy:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void onShareApp() {
    Get.find<ShareService>().shareApp(context);
  }
}
