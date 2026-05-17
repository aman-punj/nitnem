import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

class SacredSectionHeader extends StatelessWidget {
  const SacredSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: SacredTypography.meta.copyWith(
          color: c.accentSoft,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
