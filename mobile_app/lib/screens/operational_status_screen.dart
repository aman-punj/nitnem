import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';

enum OperationalStatus { maintenance, forceUpdate, minorUpdate }

class OperationalStatusScreen extends StatelessWidget {
  final OperationalStatus status;
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final String? storeUrl;
  final VoidCallback? onSecondaryPressed;

  const OperationalStatusScreen({
    super.key,
    required this.status,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.storeUrl,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showKhandaSymbol: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Immersive Icon
              Container(
                padding: const EdgeInsets.all(SacredSpacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SacredColors.primaryAccent.withValues(alpha: 0.05),
                  border: Border.all(
                    color: SacredColors.primaryAccent.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  status == OperationalStatus.maintenance 
                      ? Icons.pause_circle_outline_rounded 
                      : Icons.system_update_rounded,
                  size: 48,
                  color: SacredColors.primaryAccent,
                ),
              ),
              const SizedBox(height: SacredSpacing.xl),
              
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: SacredTypography.headlineLg.copyWith(
                  color: SacredColors.textPrimary,
                ),
              ),
              const SizedBox(height: SacredSpacing.sm),
              
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: SacredTypography.bodyMd.copyWith(
                  color: SacredColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: SacredSpacing.xxl),
              
              // Primary CTA
              SizedBox(
                width: double.infinity,
                child: SacredButton(
                  label: primaryButtonText,
                  onPressed: () async {
                    if (storeUrl != null) {
                      final Uri url = Uri.parse(storeUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    } else if (status == OperationalStatus.maintenance) {
                      // Logic for closing app
                    }
                  },
                ),
              ),
              
              // Secondary CTA
              if (secondaryButtonText != null) ...[
                const SizedBox(height: SacredSpacing.md),
                TextButton(
                  onPressed: onSecondaryPressed,
                  child: Text(
                    secondaryButtonText!,
                    style: SacredTypography.bodySm.copyWith(
                      color: SacredColors.textSecondary.withValues(alpha: 0.6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
