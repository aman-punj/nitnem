import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

class SacredSectionHeader extends StatelessWidget {
  const SacredSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: SacredTypography.meta.copyWith(
          color: SacredColors.accentSoft,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
