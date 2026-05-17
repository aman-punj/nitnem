import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';

class FrostedSettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FrostedSettingsCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: TextStyle(
              color: c.primaryAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 12),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? c.surfaceContainerLow.withValues(alpha: 0.5)
            : c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SacredRadius.xl),
        border: Border.all(
          color: c.borderGold.withValues(alpha: isDark ? 0.12 : 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: isDark ? 15 : 6,
            offset: Offset(0, isDark ? 4 : 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SacredRadius.xl),
        child: isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
