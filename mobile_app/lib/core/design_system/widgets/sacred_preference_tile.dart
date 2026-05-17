import 'package:flutter/material.dart';
import 'package:nitnem/models/preference_module.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class SacredPreferenceTile extends StatelessWidget {
  const SacredPreferenceTile({
    super.key,
    required this.module,
    required this.onTap,
    this.toggleValue,
  });

  final PreferenceModule module;
  final VoidCallback onTap;
  final bool? toggleValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SacredSpacing.sm),
      decoration: BoxDecoration(
        color: SacredColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SacredRadius.md),
        border: Border.all(
          color: SacredColors.borderGold.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SacredRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.marginMobile, vertical: SacredSpacing.gutter),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: SacredSpacing.marginMobile),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: SacredTypography.bodyMd.copyWith(
                          color: SacredColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (module.description.isNotEmpty) ...[
                        const SizedBox(height: SacredSpacing.xs),
                        Text(
                          module.description,
                          style: SacredTypography.bodySm.copyWith(
                            color: SacredColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildTrailingAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData = _getIconData(module.icon);
    return Container(
      padding: const EdgeInsets.all(SacredSpacing.sm),
      decoration: BoxDecoration(
        color: SacredColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SacredRadius.def),
      ),
      child: Icon(
        iconData,
        color: SacredColors.primaryAccent,
        size: 24,
      ),
    );
  }

  Widget _buildTrailingAction() {
    switch (module.type) {
      case PreferenceModuleType.toggle:
        return Switch(
          value: toggleValue ?? true,
          onChanged: (val) => onTap(),
          activeColor: SacredColors.primaryAccent,
          activeTrackColor: SacredColors.primaryAccent.withValues(alpha: 0.2),
        );
      case PreferenceModuleType.slider:
        return const Icon(
          Icons.linear_scale_rounded,
          color: SacredColors.textSecondary,
          size: 20,
        );
      case PreferenceModuleType.navigation:
      case PreferenceModuleType.bottomSheet:
      case PreferenceModuleType.dialog:
      case PreferenceModuleType.externalLink:
        return Icon(
          Icons.arrow_forward_ios_rounded,
          color: SacredColors.textSecondary.withValues(alpha: 0.5),
          size: 14,
        );
      case PreferenceModuleType.action:
        return const SizedBox.shrink();
    }
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'palette': return Icons.palette_rounded;
      case 'translate': return Icons.translate_rounded;
      case 'format_size': return Icons.format_size_rounded;
      case 'volunteer_activism': return Icons.volunteer_activism_rounded;
      case 'feedback': return Icons.feedback_rounded;
      case 'notifications': return Icons.notifications_rounded;
      case 'cloud_download': return Icons.cloud_download_rounded;
      case 'info': return Icons.info_rounded;
      case 'help': return Icons.help_rounded;
      default: return Icons.settings_rounded;
    }
  }
}
