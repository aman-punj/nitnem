import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    getAppInfo();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/khanda_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black87,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getAppInfo() async {
    final controller = Get.find<AppInfoController>();
    final appInfo = await controller.loadAppInfo();

    if (appInfo == null) return;


    final packageInfo = await PackageInfo.fromPlatform();
    final localVersion = packageInfo.version;

    if (appInfo.forceUpdate && appInfo.currentVersion != localVersion) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Update Required"),
          content: Text(appInfo.updateNotes),
          actions: [
            TextButton(
              onPressed: () {
              },
              child: const Text("Update Now"),
            )
          ],
        ),
      );
      return;
    }

    if (appInfo.minorUpdateAvailable) {
      final lastAppliedPatchVersion = SharedPrefsService.getPatchNum();
      if (lastAppliedPatchVersion != appInfo.currentVersion) {

        //TODO: Need to add here
        // await applyMinorPatch(appInfo.currentVersion);
        await SharedPrefsService.setPatchNum(appInfo.currentVersion);
      }
    }
  }

}
