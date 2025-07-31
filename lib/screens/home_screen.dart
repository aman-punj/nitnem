import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/screens/prayer_page.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';

import '../controllers/home_controller.dart';
import '../utils/nitnem_appbar.dart';
import 'drawer.dart';
import 'feedback_screen.dart';
import 'listing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return GradientScaffold(
      appBar: SimpleNitnemAppBar(
        title: 'Bani Sagar',
        centerTitle: true,
      ),
      drawer: HomeDrawer(onItemSelected: (item) => _onDrawerItemSelect(item)),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
        itemCount: controller.baniList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bani = controller.baniList[index];
          final title = bani[controller.currentLang] ?? bani['pa']!;
          return _buildBaniTile(bani['id']!, title);
        },
      ),
    );
  }

  Widget _buildBaniTile(String id, String title) {
    return BaniListTile(
      title: title,
      onTap: () {
        Get.to(() => PrayerPage(
          title: title,
          audioAssetPath: 'assets/audios/Japji_Sahib.mp3',
          transcriptAssetPath: 'assets/texts/Japji_Sahib.json',
        ));
      },
    );
  }

  void _onDrawerItemSelect(item) {
    Get.back();
    switch (item.id) {
      case 'language':
      // TODO: implement language toggle later
        break;
      case 'feedback':
        Get.to(() => FeedbackScreen());
        break;
      case 'exit':
        SystemNavigator.pop();
        break;
    }
  }
}
