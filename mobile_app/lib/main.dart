import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:get/get.dart';
import 'package:nitnem/controllers/font_size_controller.dart';
import 'package:nitnem/controllers/theme_controller.dart';
import 'package:nitnem/screens/splash_screen.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/core/design_system/models/theme_config.dart';
import 'package:nitnem/core/design_system/theme/app_theme.dart';
import 'package:nitnem/bindings/di.dart';
import 'package:nitnem/firebase_options.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await SharedPrefsService.init();
      await DependencyInjection.init();

      runApp(const MyApp());

      await DependencyInjection.initAudioBackground();
    },
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final fontSizeController = Get.find<FontSizeController>();

    return Obx(() {
      fontSizeController.fontSizeScale; // Observe scale changes
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode.value,
        theme: AppTheme.resolve(const ThemeConfig(themeId: 'sacred_radiance_light', amoled: false)),
        darkTheme: AppTheme.resolve(const ThemeConfig(amoled: true)),
        home: const SplashScreen(),
      );
    });
  }
}
