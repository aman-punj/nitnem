import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/screens/listing_screen.dart';
import 'package:nitnem/screens/feedback_screen.dart';
import 'package:nitnem/screens/drawer.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: SacredDsAppBar(
        title: 'Bani Sagar',
        appBarStyle: TextStyle(
          fontSize: 24,
          color: SacredColors.primary
        )
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: const ListingScreen(),
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
      const imageAssetPath = 'assets/images/bani_sagar_logo.png';
      const fallbackApkUrl =
          'https://drive.google.com/file/d/your_apk_id/view?usp=sharing';

      final byteData = await rootBundle.load(imageAssetPath);
      final buffer = byteData.buffer;

      final tempDir = await getTemporaryDirectory();
      final tempImageFile = File('${tempDir.path}/bani_sagar_logo.png');
      await tempImageFile.writeAsBytes(buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(tempImageFile.path)],
        text:
            '🌟 Check out the Bani Sagar app!\n\n🔗 $fallbackApkUrl\n\nFeel the divine connection daily 🙏',
        subject: 'Bani Sagar - Daily Nitnem & Bani App',
      );
    } catch (e) {
      print('Sharing failed: $e');
    }
  }
}
