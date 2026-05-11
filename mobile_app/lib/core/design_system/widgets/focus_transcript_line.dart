import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';

class FocusTranscriptLine extends StatelessWidget {
  const FocusTranscriptLine({
    super.key,
    required this.text,
    required this.isPlaybackHighlighted,
    required this.isFocusHighlighted,
    required this.isFocusMode,
  });

  final String text;
  final bool isPlaybackHighlighted;
  final bool isFocusHighlighted;
  final bool isFocusMode;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = isPlaybackHighlighted || isFocusHighlighted;
    final opacity = isFocusMode && !isFocusHighlighted ? 0.42 : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: SacredMotion.normal),
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? SacredColors.focusedLine : Colors.transparent,
          borderRadius: BorderRadius.circular(SacredRadius.sm),
          border: isHighlighted ? Border.all(color: SacredColors.primaryAccent) : null,
        ),
        child: Text(
          text,
          style: SacredTypography.transcript.copyWith(
            color: SacredColors.textPrimary,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
