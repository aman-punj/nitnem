import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/preference_controller.dart';
import '../core/design_system/tokens/colors.dart';
import '../core/design_system/widgets/sacred_app_bar.dart';
import '../core/design_system/widgets/sacred_loader.dart';
import '../core/design_system/widgets/sacred_preference_tile.dart';
import '../utils/gradient_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreferenceController());

    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: const SacredDsAppBar(
        title: 'Settings',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SacredLoader(text: 'Loading preferences...');
        }

        return RefreshIndicator(
          onRefresh: controller.fetchModules,
          color: SacredColors.primaryAccent,
          backgroundColor: SacredColors.surfaceContainerLow,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: controller.modules.length,
            itemBuilder: (context, index) {
              final module = controller.modules[index];
              return SacredPreferenceTile(
                module: module,
                toggleValue: controller.toggleStates[module.id],
                onTap: () => controller.handleEvent(module.event, module),
              );
            },
          ),
        );
      }),
    );
  }
}
