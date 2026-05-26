import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? iconAsset;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.iconAsset,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              padding: const EdgeInsets.all(8),
              child: iconAsset != null
                  ? SvgPicture.asset(
                      iconAsset!,
                      colorFilter: ColorFilter.mode(c.primaryAccent, BlendMode.srcIn),
                    )
                  : Icon(icon, color: c.primaryAccent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: c.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
