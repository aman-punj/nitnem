import 'package:flutter/material.dart';

import '../tokens/colors.dart';

class SacredDsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SacredDsAppBar({super.key, required this.title, this.actions, this.appBarStyle});

  final String title;
  final List<Widget>? actions;
  final TextStyle? appBarStyle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(
          bottom: BorderSide(
            color: c.borderGold.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        title: Text(
          title,
          style: appBarStyle ?? const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: actions,
      ),
    );
  }
}
