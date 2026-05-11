import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class SacredLoader extends StatelessWidget {
  final String? text;

  const SacredLoader({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: SacredColors.primaryAccent,
            strokeWidth: 2,
          ),
          if (text != null) ...[
            const SizedBox(height: 24),
            Text(
              text!,
              style: const TextStyle(
                color: SacredColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
