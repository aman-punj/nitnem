import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';

class SacredButton extends StatelessWidget {
  const SacredButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: SacredColors.primaryAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SacredRadius.sm)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
