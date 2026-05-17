import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';

class SacredButton extends StatelessWidget {
  const SacredButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.variant = SacredButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final SacredButtonVariant variant;

  bool get _isPrimary => variant == SacredButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isPrimary ? SacredColors.primaryAccent : SacredColors.surfaceContainer,
        foregroundColor: _isPrimary ? Colors.black : SacredColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SacredRadius.sm),
          side: _isPrimary
              ? BorderSide.none
              : BorderSide(color: SacredColors.borderGold.withValues(alpha: 0.25)),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

enum SacredButtonVariant { primary, secondary }
