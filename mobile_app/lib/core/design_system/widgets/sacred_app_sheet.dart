import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 36),
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
                const SizedBox(height: 28),
                Text(
                  title,
                  style: SacredTypography.headlineLg.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: SacredTypography.bodyMd.copyWith(
                    color: SacredColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SacredColors.primaryAccent,
                      foregroundColor: SacredColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      primaryButtonText,
                      style: SacredTypography.bodyMd.copyWith(
                        color: SacredColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (secondaryButtonText != null) ...[
                  const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                const SafeArea(child: SizedBox.shrink()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
