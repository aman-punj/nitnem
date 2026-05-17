import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/privacy_policy_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_loader.dart';
import 'package:nitnem/services/support_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({super.key});

  final PrivacyPolicyController controller = Get.put(
    PrivacyPolicyController(supportService: Get.find<SupportService>()),
    tag: 'privacy_policy_controller',
  );

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const SacredDsAppBar(title: 'Privacy Policy'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SacredLoader(text: 'Loading privacy policy...');
        }

        return ListView(
          padding: const EdgeInsets.all(SacredSpacing.marginMobile),
          children: [
            FrostedSettingsCard(
              title: controller.content.value.title,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SacredSpacing.marginMobile,
                    SacredSpacing.base,
                    SacredSpacing.marginMobile,
                    SacredSpacing.marginMobile,
                  ),
                  child: SelectableText(
                    controller.content.value.content,
                    style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
