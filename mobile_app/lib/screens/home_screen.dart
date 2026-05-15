import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/feedback_screen.dart';
import 'package:nitnem/screens/manage_notifications_screen.dart';
import 'package:nitnem/screens/drawer.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
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
    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: SacredDsAppBar(
        title: 'Bani Sagar',
        appBarStyle: const TextStyle(
          fontSize: 24,
          color: SacredColors.primary
        )
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: const ListingScreen(),
    );
  }

  void _onDrawerItemSelect(dynamic item) {
    Get.back();
    switch (item.id) {
      case 'notifications':
        Get.to(() => const ManageNotificationsScreen());
        break;
      case 'language':
        break;
      case 'share':
        onShareApp();
        break;
      case 'feedback':
        Get.to(() => FeedbackScreen());
        break;
      case 'exit':
        SystemNavigator.pop();
        break;
    }
  }

  void onShareApp() {
    Get.find<ShareService>().shareApp(context);
  }
}
