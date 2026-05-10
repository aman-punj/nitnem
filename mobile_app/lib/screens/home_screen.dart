import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/home_controller.dart';
import '../utils/nitnem_appbar.dart';
import 'drawer.dart';
import 'feedback_screen.dart';
import 'listing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GradientScaffold(
      appBar: SimpleNitnemAppBar(
        title: 'Bani Sagar',
        centerTitle: true,
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 12, left: 18, right: 18),
        itemCount: controller.baniList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bani = controller.baniList[index];
          final title = bani[controller.currentLang] ?? bani['pa']!;
          return _buildBaniTile(bani['id']!, title, controller);
        },
      ),
    );
  }

  Widget _buildBaniTile(String id, String title,HomeController controller) {
    return BaniListTile(
      title: title,
      onTap: ()=> controller.openPrayer(id, title),
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
      const fallbackApkUrl =
          'https://drive.google.com/file/d/your_apk_id/view?usp=sharing'; // Replace with your actual APK link

      // Load image from assets
      final byteData = await rootBundle.load(imageAssetPath);
      final buffer = byteData.buffer;

      // Write image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempImageFile = File('${tempDir.path}/khanda_image.png');
      await tempImageFile.writeAsBytes(buffer.asUint8List());

      // Share image + text
      final shareData = ShareParams(
        text:
            '🌟 Check out the Bani Sagar app!\n\n🔗 $fallbackApkUrl\n\nFeel the divine connection daily 🙏',
        subject: 'Bani Sagar - Daily Nitnem & Bani App',
        files: [XFile(tempImageFile.path)],
      );

      SharePlus.instance.share(shareData);
    } catch (e) {
      print('Sharing failed: $e');
    }
  }
}
