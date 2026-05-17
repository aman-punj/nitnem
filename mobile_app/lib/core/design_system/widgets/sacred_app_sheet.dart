import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';

enum SacredAppSheetType { info, update, maintenance }

class SacredAppSheet extends StatelessWidget {
  final String title;
  final String body;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final SacredAppSheetType type;

  const SacredAppSheet({
    super.key,
    required this.title,
    required this.body,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.type = SacredAppSheetType.info,
  });

  IconData get _icon {
    switch (type) {
      case SacredAppSheetType.update:
        return Icons.system_update_alt_rounded;
      case SacredAppSheetType.maintenance:
        return Icons.engineering_rounded;
      case SacredAppSheetType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SacredColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(SacredRadius.xl)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SacredColors.surfaceContainerLow,
                      SacredColors.surfaceContainerLow,
                      SacredColors.primaryAccent.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: SacredColors.surfaceContainerLow
                        .withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(SacredSpacing.md, SacredSpacing.marginMobile, SacredSpacing.md, SacredSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SacredSpacing.lg),
                  decoration: BoxDecoration(
                    color: SacredColors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SacredColors.primaryAccent.withValues(alpha: 0.12),
                    border: Border.all(
                      color: SacredColors.primaryAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _icon,
                    size: 40,
                    color: SacredColors.primaryAccent,
                  ),
                ),
                const SizedBox(height: SacredSpacing.md),
                Text(
                  title,
                  style: SacredTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SacredSpacing.gutter),
                Text(
                  body,
                  style: SacredTypography.bodyMd.copyWith(
                    color: SacredColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SacredSpacing.lg),
                SacredButton(
                  label: primaryButtonText,
                  onPressed: onPrimaryPressed,
                  fullWidth: true,
                ),
                if (secondaryButtonText != null) ...[
                  const SizedBox(height: SacredSpacing.gutter),
                  TextButton(
                    onPressed:
                        onSecondaryPressed ?? () => Navigator.pop(context),
                    child: Text(
                      secondaryButtonText!,
                      style: SacredTypography.labelSm.copyWith(
                        color: SacredColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: SacredSpacing.sm),
                const SafeArea(child: SizedBox.shrink()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
