import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/support_form_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_sheet.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';

class SupportRequestForm extends StatelessWidget {
  const SupportRequestForm({super.key, required this.controller, this.trailingAction});

  final SupportFormController controller;
  final Widget? trailingAction;

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: SacredTypography.bodySm,
      filled: true,
      fillColor: SacredColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.all(SacredSpacing.gutter),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: BorderSide(color: SacredColors.borderGold.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: BorderSide(color: SacredColors.borderGold.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: const BorderSide(color: SacredColors.primaryAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: SacredSpacing.marginMobile,
        vertical: SacredSpacing.sm,
      ),
      children: [
        FrostedSettingsCard(
          title: controller.pageTitle.toUpperCase(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: SacredSpacing.base),
                  Text(
                    controller.requestTypeValue == 'feedback'
                        ? 'Share your thoughts to help us improve.'
                        : 'Describe the issue clearly so we can resolve it quickly.',
                    style: SacredTypography.meta,
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.titleController,
                    style: SacredTypography.bodyMd,
                    decoration: _decoration('Title'),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.messageController,
                    maxLines: 7,
                    style: SacredTypography.bodyMd,
                    decoration: _decoration('Message'),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.emailController,
                    style: SacredTypography.bodyMd,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('Email (optional)'),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  Obx(() => SacredButton(
                        label: controller.isSubmitting.value ? 'Submitting...' : 'Submit',
                        fullWidth: true,
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final success = await controller.submit();
                                if (!success) return;
                                await showModalBottomSheet<void>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (sheetContext) => SacredAppSheet(
                                    title: 'Submitted',
                                    body: 'Your ${controller.requestTypeValue} was received successfully.',
                                    primaryButtonText: 'Done',
                                    onPrimaryPressed: () {
                                      Navigator.of(sheetContext).pop();
                                      Get.back();
                                    },
                                  ),
                                );
                              },
                      )),
                  if (trailingAction != null) ...[
                    const SizedBox(height: SacredSpacing.gutter),
                    trailingAction!,
                  ],
                  const SizedBox(height: SacredSpacing.marginMobile),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
