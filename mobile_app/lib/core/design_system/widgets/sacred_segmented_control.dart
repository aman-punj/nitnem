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
    final c = SacredColors.of(context);
    return Container(
      padding: EdgeInsets.all(isSecondary ? 3 : 4),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SacredRadius.full),
        border: Border.all(
          color: c.borderGold.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Flexible(
            child: GestureDetector(
              onTap: () => onSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: SacredMotion.normal),
                padding: EdgeInsets.symmetric(
                  horizontal: isSecondary ? 12 : 24,
                  vertical: isSecondary ? 4 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? c.primaryAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(SacredRadius.full),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c.primaryAccent.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: (isSecondary ? SacredTypography.labelSm : SacredTypography.bodyMd).copyWith(
                      color: isSelected ? c.onPrimary : c.textSecondary,
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
