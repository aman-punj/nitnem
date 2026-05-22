import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperSupportScreen extends StatelessWidget {
  const DeveloperSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final controller = Get.find<AppInfoController>();

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const SacredDsAppBar(title: 'Support Development'),
      body: Obx(() {
        final support = controller.developerSupport.value;
        final kofiEnabled = controller.appConfig.value?.features.kofiEnabled ?? false;

        if (support == null || !support.isConfigured) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SacredSpacing.marginMobile),
              child: Text(
                'Support options are not available right now.',
                style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: SacredSpacing.marginMobile,
            vertical: SacredSpacing.sm,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SacredSpacing.base,
                vertical: SacredSpacing.gutter,
              ),
              child: Text(
                'Your support keeps this app free and growing. Every contribution helps — Waheguru bless you.',
                style: SacredTypography.bodySm.copyWith(
                  color: c.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (support.hasUpi) ...[
              FrostedSettingsCard(
                title: 'PAY VIA UPI',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SacredSpacing.marginMobile,
                      SacredSpacing.base,
                      SacredSpacing.marginMobile,
                      SacredSpacing.marginMobile,
                    ),
                    child: Column(
                      children: [
                        if (support.upiQrUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(SacredRadius.md),
                            child: Image.network(
                              support.upiQrUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                      color: c.primaryAccent,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, _, __) => SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: Icon(Icons.qr_code, size: 80, color: c.textSecondary),
                                ),
                              ),
                            ),
                          ),
                        if (support.upiId.isNotEmpty) ...[
                          const SizedBox(height: SacredSpacing.gutter),
                          Text(
                            'UPI ID',
                            style: SacredTypography.meta.copyWith(color: c.textSecondary),
                          ),
                          const SizedBox(height: SacredSpacing.xs),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: support.upiId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'UPI ID copied',
                                    style: SacredTypography.bodySm,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SacredSpacing.gutter,
                                vertical: SacredSpacing.base,
                              ),
                              decoration: BoxDecoration(
                                color: c.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(SacredRadius.md),
                                border: Border.all(color: c.borderGold.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    support.upiId,
                                    style: SacredTypography.bodyMd.copyWith(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: SacredSpacing.base),
                                  Icon(Icons.copy, size: 16, color: c.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SacredSpacing.md),
            ],
            if (support.hasKofi && kofiEnabled)
              FrostedSettingsCard(
                title: 'SUPPORT ON KO-FI',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SacredSpacing.marginMobile,
                      SacredSpacing.base,
                      SacredSpacing.marginMobile,
                      SacredSpacing.marginMobile,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'International payments via card or PayPal.',
                          style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SacredSpacing.gutter),
                        SacredButton(
                          label: 'Open Ko-fi',
                          fullWidth: true,
                          onPressed: () async {
                            final uri = Uri.parse(support.kofiUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: SacredSpacing.xxl),
          ],
        );
      }),
    );
  }
}
