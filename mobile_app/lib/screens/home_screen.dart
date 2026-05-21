import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:nitnem/controllers/hukamnama_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/widgets/hukamnama_sheet.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_sheet.dart';
import 'package:nitnem/models/hukamnama_model.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/settings_screen.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _maybeShowPermissionSheet();
      _maybeShowHukamnamaSheet();
      // Cold-start: app launched by tapping the widget
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) _openHukamnamaDetail();
    });
    // Warm-start: widget tapped while app is already running
    _widgetClickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _openHukamnamaDetail();
    });
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    super.dispose();
  }

  void _openHukamnamaDetail() {
    final ctrl = Get.find<HukamnamaController>();
    final data = ctrl.hukamnama.value;
    if (data != null) {
      _showHukamnamaSheet(data);
    } else {
      // Data still loading — show as soon as it arrives
      once(ctrl.hukamnama, (HukamnamaModel? d) {
        if (d != null) _showHukamnamaSheet(d);
      });
    }
  }

  void _showHukamnamaSheet(HukamnamaModel data) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => HukamnamaSheet(data: data),
      ),
    );
  }

  void _maybeShowPermissionSheet() {
    final prefs = SharedPrefsService.instance;

    // Never show again once the user has accepted
    if (prefs.getBool(_kPermAccepted) ?? false) return;

    final openCount = (prefs.getInt(_kAppOpenCount) ?? 0) + 1;
    prefs.setInt(_kAppOpenCount, openCount);

    // If a deferred open target is set and we haven't reached it yet, skip
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
          Get.find<NotificationService>().requestPermissions();
        },
        onSecondaryPressed: () {
          // Re-prompt after a random 10–20 opens
          final next = openCount + 10 + Random().nextInt(11);
          prefs.setInt(_kPermNextOpen, next);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _maybeShowHukamnamaSheet() {
    final ctrl = Get.find<HukamnamaController>();
    if (!ctrl.shouldShowTodaySheet()) return;

    // Wait for the controller to finish fetching before showing
    ever(ctrl.hukamnama, (data) {
      if (data == null) return;
      if (!ctrl.shouldShowTodaySheet()) return;
      ctrl.markSheetShown();
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) =>
              HukamnamaSheet(data: data),
        ),
      );
    });
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
