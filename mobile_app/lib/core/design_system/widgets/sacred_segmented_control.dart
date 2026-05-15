import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';

class SacredSegmentedControl<T> extends StatelessWidget {
  const SacredSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.isSecondary = false,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SacredColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SacredRadius.full),
        border: Border.all(
          color: SacredColors.borderGold.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max, // Changed to max
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Expanded( // Added Expanded
            child: GestureDetector(
              onTap: () => onSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: SacredMotion.normal),
                padding: EdgeInsets.symmetric(
                  horizontal: isSecondary ? 16 : 24,
                  vertical: isSecondary ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? SacredColors.primaryAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(SacredRadius.full),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: SacredColors.primaryAccent.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center( // Added Center
                  child: Text(
                    entry.value,
                    style: (isSecondary ? SacredTypography.labelSm : SacredTypography.bodyMd).copyWith(
                      color: isSelected ? Colors.black : SacredColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
