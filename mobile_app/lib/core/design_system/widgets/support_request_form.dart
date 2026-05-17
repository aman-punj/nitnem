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

  InputDecoration _decoration(String hint, SacredColors c) {
    return InputDecoration(
      hintText: hint,
      hintStyle: SacredTypography.bodySm.copyWith(color: c.textSecondary),
      filled: true,
      fillColor: c.surfaceContainerLow,
      contentPadding: const EdgeInsets.all(SacredSpacing.gutter),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: BorderSide(color: c.borderGold.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: BorderSide(color: c.borderGold.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        borderSide: BorderSide(color: c.primaryAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
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
                    style: SacredTypography.meta.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.titleController,
                    style: SacredTypography.bodyMd.copyWith(color: c.textPrimary),
                    decoration: _decoration('Title', c),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.messageController,
                    maxLines: 7,
                    style: SacredTypography.bodyMd.copyWith(color: c.textPrimary),
                    decoration: _decoration('Message', c),
                  ),
                  const SizedBox(height: SacredSpacing.gutter),
                  TextField(
                    controller: controller.emailController,
                    style: SacredTypography.bodyMd.copyWith(color: c.textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('Email (optional)', c),
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
