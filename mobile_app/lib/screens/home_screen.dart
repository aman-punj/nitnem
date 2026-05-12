import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/home_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/settings_screen.dart';
import 'package:nitnem/screens/feedback_screen.dart';
import 'package:nitnem/screens/drawer.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Library

  final List<Widget> _screens = [
    const SanctuaryPlaceholder(),
    const ListingScreen(),
    const MeditationPlaceholder(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: SacredDsAppBar(
        title: _getTitle(_currentIndex),
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Sanctuary';
      case 1: return 'Bani Sagar';
      case 2: return 'Meditation';
      case 3: return 'Settings';
      default: return 'Bani Sagar';
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: SacredColors.backgroundBlack.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: SacredColors.primaryAccent.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: SacredColors.primaryAccent.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.auto_awesome_rounded, 'Sanctuary'),
              _buildNavItem(1, Icons.menu_book_rounded, 'Library'),
              _buildNavItem(2, Icons.self_improvement_rounded, 'Meditation'),
              _buildNavItem(3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? SacredColors.primaryAccent : SacredColors.textSecondary.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: SacredTypography.labelSm.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _onDrawerItemSelect(item) {
    Get.back();
    switch (item.id) {
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

  void onShareApp() async {
    try {
      const imageAssetPath = 'assets/images/khanda_image.png';
      const fallbackApkUrl = 'https://drive.google.com/file/d/your_apk_id/view?usp=sharing';

      final byteData = await rootBundle.load(imageAssetPath);
      final buffer = byteData.buffer;

      final tempDir = await getTemporaryDirectory();
      final tempImageFile = File('${tempDir.path}/khanda_image.png');
      await tempImageFile.writeAsBytes(buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(tempImageFile.path)],
        text: '🌟 Check out the Bani Sagar app!\n\n🔗 $fallbackApkUrl\n\nFeel the divine connection daily 🙏',
        subject: 'Bani Sagar - Daily Nitnem & Bani App',
      );
    } catch (e) {
      print('Sharing failed: $e');
    }
  }
}

class SanctuaryPlaceholder extends StatelessWidget {
  const SanctuaryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Sanctuary Coming Soon',
        style: TextStyle(color: SacredColors.textSecondary),
      ),
    );
  }
}

class MeditationPlaceholder extends StatelessWidget {
  const MeditationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Meditation Coming Soon',
        style: TextStyle(color: SacredColors.textSecondary),
      ),
    );
  }
}
