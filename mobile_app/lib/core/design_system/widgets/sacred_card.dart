import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/elevation.dart';
import '../tokens/radius.dart';

class SacredCard extends StatelessWidget {
  const SacredCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: SacredColors.surfacePrimary,
        borderRadius: BorderRadius.circular(SacredRadius.md),
        border: Border.all(color: SacredColors.borderSoft),
        boxShadow: SacredElevation.soft,
      ),
      child: child,
    );
  }
}
