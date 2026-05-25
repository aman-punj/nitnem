import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:nitnem/controllers/hukamnama_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_sheet.dart';
import 'package:nitnem/models/hukamnama_model.dart';
import 'package:nitnem/screens/hukamnama_screen.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/settings_screen.dart';
import 'package:nitnem/core/design_system/widgets/mini_player_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/controllers/notification_settings_controller.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/share_service.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _kPermAccepted = 'notif_perm_accepted';
  static const _kPermNextOpen = 'notif_perm_next_open';
  static const _kAppOpenCount = 'app_open_count';

  StreamSubscription<Uri?>? _widgetClickSub;
  StreamSubscription<RemoteMessage>? _fcmOpenedSub;

  @override
  void initState() {
    super.initState();

    // Route notification taps (local notifications with hukamnama payload)
    Get.find<NotificationService>().onHukamnamaTap = _openHukamnamaDetail;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _maybeShowPermissionSheet();
      _maybeOpenHukamnamaScreen();

      // Widget cold-start (app launched by tapping the home widget)
      final widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (widgetUri != null) _openHukamnamaDetail();

      // FCM terminated-start (app opened by tapping a push notification)
      final initialMsg =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMsg != null) _openHukamnamaDetail();
    });

    // Widget warm-start (widget tapped while app is running)
    _widgetClickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _openHukamnamaDetail();
    });

    // FCM background-start (notification tapped while app is in background)
    _fcmOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((_) {
      _openHukamnamaDetail();
    });
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    _fcmOpenedSub?.cancel();
    Get.find<NotificationService>().onHukamnamaTap = null;
    super.dispose();
  }

  void _openHukamnamaDetail() {
    final ctrl = Get.find<HukamnamaController>();
    final data = ctrl.hukamnama.value;
    if (data != null) {
      Get.to(() => HukamnamaScreen(data: data));
    } else {
      once(ctrl.hukamnama, (HukamnamaModel? d) {
        if (d != null) Get.to(() => HukamnamaScreen(data: d));
      });
    }
  }

  /// Opens Hukamnama screen directly on the first daily launch (no sheet).
  void _maybeOpenHukamnamaScreen() {
    final ctrl = Get.find<HukamnamaController>();
    if (!ctrl.isEnabled.value) return;
    if (!ctrl.shouldShowTodaySheet()) return;

    if (ctrl.hukamnama.value != null) {
      ctrl.markSheetShown();
      Get.to(() => HukamnamaScreen(data: ctrl.hukamnama.value!));
      return;
    }

    once(ctrl.hukamnama, (HukamnamaModel? data) {
      if (data == null) return;
      if (!ctrl.isEnabled.value) return;
      if (!ctrl.shouldShowTodaySheet()) return;
      ctrl.markSheetShown();
      Get.to(() => HukamnamaScreen(data: data));
    });
  }

  void _maybeShowPermissionSheet() {
    final prefs = SharedPrefsService.instance;

    if (prefs.getBool(_kPermAccepted) ?? false) return;

    final openCount = (prefs.getInt(_kAppOpenCount) ?? 0) + 1;
    prefs.setInt(_kAppOpenCount, openCount);

    final nextOpen = prefs.getInt(_kPermNextOpen);
    if (nextOpen != null && openCount < nextOpen) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SacredAppSheet(
        title: 'Stay in Rhythm',
        body: 'Nitnem reminds you of morning and evening prayers at just the right time. '
            'Allow notifications so your reminders always arrive — even when the app is closed.',
        primaryButtonText: 'Allow',
        secondaryButtonText: 'Maybe Later',
        onPrimaryPressed: () {
          prefs.setBool(_kPermAccepted, true);
          Navigator.pop(context);
          Get.find<NotificationService>().requestBasicPermissions().then((_) {
            if (Get.isRegistered<NotificationSettingsController>()) {
              Get.find<NotificationSettingsController>().rescheduleAll();
            }
          });
        },
        onSecondaryPressed: () {
          final next = openCount + 10 + Random().nextInt(11);
          prefs.setInt(_kPermNextOpen, next);
          Navigator.pop(context);
        },
      ),
    );
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
      body: Column(
        children: [
          const Expanded(child: ListingScreen()),
          const MiniPlayerBar(),
        ],
      ),
    );
  }

  void onShareApp() {
    Get.find<ShareService>().shareApp(context);
  }
}
