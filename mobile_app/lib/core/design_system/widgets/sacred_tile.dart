import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';

class SacredTile extends StatelessWidget {
  const SacredTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return ListTile(
      tileColor: c.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SacredRadius.md),
        side: BorderSide(color: c.borderSoft),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: c.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: c.accentSoft),
      onTap: onTap,
    );
  }
}
