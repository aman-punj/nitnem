import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/widgets/sacred_section_header.dart';
import 'package:nitnem/core/design_system/widgets/sacred_tile.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/home_controller.dart';
import '../core/design_system/widgets/sacred_app_bar.dart';
import 'drawer.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: const SacredDsAppBar(
        title: 'Bani Sagar',
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: Obx(() {
        if (controller.isLoading.value && controller.contentItems.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: SacredColors.primaryAccent, strokeWidth: 2));
        }

        final grouped = controller.groupedContent;
        final categoryIds = grouped.keys.toList();

        return RefreshIndicator(
          onRefresh: controller.refreshContent,
          color: SacredColors.primaryAccent,
          backgroundColor: SacredColors.surfacePrimary,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, left: 18, right: 18),
            itemCount: categoryIds.length,
            itemBuilder: (context, index) {
              final categoryId = categoryIds[index];
              final sectionItems = grouped[categoryId] ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SacredSectionHeader(title: _categoryTitle(categoryId)),
                  ...sectionItems.map((content) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildContentTile(content, controller),
                      )),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildContentTile(content, HomeController controller) {
    return SacredTile(
      title: content.titles.getForLanguage(controller.currentLang.value),
      subtitle: content.type.toString().split('.').last.toUpperCase(),
      onTap: () => controller.onContentTap(content),
    );
  }

  String _categoryTitle(String categoryId) {
    return categoryId
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
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
