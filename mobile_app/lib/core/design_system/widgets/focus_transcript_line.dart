import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tokens/colors.dart';
import '../tokens/motion.dart';
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
    
    // In Focus Mode, non-highlighted lines are significantly more muted.
    // In Standard mode, we use a softer opacity hierarchy.
    final double opacity = isHighlighted 
        ? 1.0 
        : (isFocusMode ? 0.25 : 0.6);
    
    final double scale = isHighlighted ? 1.02 : 1.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: SacredMotion.slow),
      scale: scale,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: SacredMotion.normal),
        opacity: opacity,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Obx(() => Text(
                text,
                textAlign: TextAlign.center,
                style: SacredTypography.transcript.copyWith(

                  color: isHighlighted ? SacredColors.primaryAccent : SacredColors.textPrimary,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  shadows: isHighlighted ? [
                    Shadow(
                      color: SacredColors.primaryAccent.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ] : null,
                ),
              )),
              if (isHighlighted)
                AnimatedContainer(
                  duration: const Duration(milliseconds: SacredMotion.normal),
                  margin: const EdgeInsets.only(top: 8),
                  height: 1,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        SacredColors.primaryAccent.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
