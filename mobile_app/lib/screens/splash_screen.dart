import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/screens/operational_status_screen.dart';
import 'package:nitnem/services/firebase_content_service.dart';
import 'package:nitnem/services/transcript_sync_service.dart';
import 'package:nitnem/models/content_item.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
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
  late AnimationController _loadingController;
  bool _isOperationalBlocked = false;

  @override
  void initState() {
    super.initState();
    _initApp();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController.forward();
  }

  Future<void> _initApp() async {
    await getAppInfo();
    
    if (_isOperationalBlocked) return;

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showKhandaSymbol: false,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Atmospheric Glow
            Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SacredColors.primaryAccent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Central Branding
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SacredColors.surfaceContainerLow.withValues(alpha: 0.5),
                      border: Border.all(
                        color: SacredColors.primaryAccent.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SacredColors.primaryAccent.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/bani_sagar_logo.png',
                        width: 60,
                        height: 60,
                        // Fallback icon if image missing
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.spa_rounded,
                          color: SacredColors.primaryAccent,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Bani Sagar',
                    style: SacredTypography.displayLg.copyWith(
                      color: SacredColors.primaryAccent,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Sacred Sound. Calm Presence.',
                    style: SacredTypography.headlineMd.copyWith(
                      color: SacredColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            // Loading Section
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Elegant Loading Bar
                  Container(
                    width: 180,
                    height: 2,
                    decoration: BoxDecoration(
                      color: SacredColors.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment(
                            -1.0 + (Curves.easeInOut.transform(_loadingController.value) * 2),
                            0,
                          ),
                          widthFactor: 0.3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: SacredColors.primaryAccent.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: SacredColors.primaryAccent.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FINDING STILLNESS',
                    style: SacredTypography.labelSm.copyWith(
                      color: SacredColors.textSecondary.withValues(alpha: 0.4),
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: SacredColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Crafted for Mindfulness',
                    style: SacredTypography.bodySm.copyWith(
                      fontSize: 11,
                      color: SacredColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAppInfo() async {
    final controller = Get.find<AppInfoController>();
    await controller.loadAppInfo();

    if (controller.appInfo.value == null) return;

    // 1. Check Maintenance
    if (controller.isUnderMaintenance) {
      if (mounted) {
        setState(() => _isOperationalBlocked = true);
        _navigateToOperationalStatus(
          status: OperationalStatus.maintenance,
          message: controller.maintenanceMessage,
        );
      }
      return;
    }

    // 2. Check Force Update
    if (await controller.shouldForceUpdate()) {
      if (mounted) {
        setState(() => _isOperationalBlocked = true);
        final config = controller.appInfo.value!.versionControl;
        _navigateToOperationalStatus(
          status: OperationalStatus.forceUpdate,
          message: config.updateMessage,
          storeUrl: Platform.isAndroid ? config.androidStoreUrl : config.iosStoreUrl,
        );
      }
      return;
    }

    // 3. Recommended Update (Non-blocking)
    if (await controller.shouldRecommendUpdate()) {
      _handleRecommendedUpdate();
    }
  }

  void _navigateToOperationalStatus({
    required OperationalStatus status,
    required String message,
    String? storeUrl,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OperationalStatusScreen(
          status: status,
          message: message,
          storeUrl: storeUrl,
        ),
      ),
    );
  }

  void _handleRecommendedUpdate() {
    _syncContent();
  }

  Future<void> _syncContent() async {
    try {
      final firebaseContentService = Get.find<FirebaseContentService>();
      final transcriptSyncService = Get.find<TranscriptSyncService>();

      final List<ContentItem> remoteItems = await firebaseContentService.fetchContentCatalog();

      for (final item in remoteItems) {
        await transcriptSyncService.syncContent(item);
      }
    } catch (e) {
      // Silent fail for sync in splash
    }
  }
}
