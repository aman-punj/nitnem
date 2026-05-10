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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GradientScaffold(
      showKhandaSymbol: true,
      appBar: SimpleNitnemAppBar(
        title: 'Bani Sagar',
        centerTitle: true,
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: Obx(() {
        if (controller.isLoading.value && controller.contentItems.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshContent,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 12, left: 18, right: 18),
            itemCount: controller.contentItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final content = controller.contentItems[index];
              return _buildContentTile(content, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildContentTile(content, HomeController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          content.titles.getForLanguage(controller.currentLang.value),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content.type.name.toUpperCase()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => controller.onContentTap(content),
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
