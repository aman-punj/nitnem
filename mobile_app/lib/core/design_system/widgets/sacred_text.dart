import 'package:flutter/material.dart';

import '../tokens/typography.dart';

class SacredText extends StatelessWidget {
  const SacredText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? SacredTypography.body);
  }
}
