import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/faq_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:nitnem/core/design_system/widgets/sacred_loader.dart';
import 'package:nitnem/services/support_service.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final FaqController controller = Get.put(
    FaqController(supportService: Get.find<SupportService>()),
    tag: 'faq_controller',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: const SacredDsAppBar(title: 'FAQ'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SacredLoader(text: 'Loading FAQ...');
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return ListView(
            padding: const EdgeInsets.all(SacredSpacing.marginMobile),
            children: [
              FrostedSettingsCard(
                title: 'FAQ',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SacredSpacing.marginMobile,
                      SacredSpacing.base,
                      SacredSpacing.marginMobile,
                      SacredSpacing.marginMobile,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.errorMessage.value, style: SacredTypography.bodySm),
                        const SizedBox(height: SacredSpacing.gutter),
                        SacredButton(label: 'Retry', onPressed: controller.load),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        if (controller.items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(SacredSpacing.marginMobile),
            children: [
              FrostedSettingsCard(
                title: 'FAQ',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SacredSpacing.marginMobile,
                      SacredSpacing.base,
                      SacredSpacing.marginMobile,
                      SacredSpacing.marginMobile,
                    ),
                    child: Text('No FAQ available yet.', style: SacredTypography.bodySm),
                  ),
                ],
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(SacredSpacing.marginMobile),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: SacredSpacing.base,
                right: SacredSpacing.base,
                bottom: SacredSpacing.gutter,
              ),
              child: Text(
                'Common questions and answers',
                style: SacredTypography.meta,
              ),
            ),
            ...controller.items.map(
              (item) => FrostedSettingsCard(
                title: 'QUESTION',
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: SacredSpacing.marginMobile),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        SacredSpacing.marginMobile,
                        0,
                        SacredSpacing.marginMobile,
                        SacredSpacing.marginMobile,
                      ),
                      title: Text(item.question, style: SacredTypography.bodyMd.copyWith(color: SacredColors.textPrimary)),
                      iconColor: SacredColors.primaryAccent,
                      collapsedIconColor: SacredColors.primaryAccent,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item.answer, style: SacredTypography.bodySm),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
