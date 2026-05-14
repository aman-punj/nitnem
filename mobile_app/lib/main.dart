import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:get/get.dart';
import 'package:nitnem/screens/splash_screen.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/core/design_system/models/theme_config.dart';
import 'package:nitnem/core/design_system/theme/app_theme.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nitnem/bindings/di.dart';
import 'package:nitnem/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'drawable/ic_notification',
    fastForwardInterval: const Duration(seconds: 10),
    rewindInterval: const Duration(seconds: 10),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPrefsService.init();

  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.resolve(const ThemeConfig(amoled: true)),
      home: const SplashScreen(),
    );
  }
}
