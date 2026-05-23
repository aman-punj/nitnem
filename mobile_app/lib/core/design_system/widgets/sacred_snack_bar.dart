import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';

void showSacredSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
}) {
  final c = SacredColors.of(context);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: SacredSpacing.marginMobile,
          vertical: SacredSpacing.gutter,
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SacredSpacing.gutter,
            vertical: SacredSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(SacredRadius.md),
            border: Border.all(color: c.borderGold.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: c.primaryAccent),
                const SizedBox(width: SacredSpacing.base),
              ],
              Expanded(
                child: Text(
                  message,
                  style: SacredTypography.bodySm.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
