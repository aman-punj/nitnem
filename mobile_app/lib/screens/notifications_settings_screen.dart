import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/notification_settings_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';

class NotificationsSettingsScreen extends GetView<NotificationSettingsController> {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const SacredDsAppBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SacredSpacing.marginMobile,
          SacredSpacing.md,
          SacredSpacing.marginMobile,
          SacredSpacing.xl,
        ),
        children: [
          FrostedSettingsCard(
            title: 'DAILY PRAYERS',
            children: [
              Obx(() => _NotifTile(
                    icon: Icons.wb_sunny_rounded,
                    title: 'Morning Nitnem',
                    time: controller.morningTime.value,
                    enabled: controller.morningEnabled.value,
                    onToggle: controller.setMorningEnabled,
                    onTimeTap: () => _pickTime(
                      context,
                      controller.morningTime.value,
                      controller.setMorningTime,
                    ),
                  )),
              _Divider(c: c),
              Obx(() => _NotifTile(
                    icon: Icons.nights_stay_rounded,
                    title: 'Evening Nitnem',
                    time: controller.eveningTime.value,
                    enabled: controller.eveningEnabled.value,
                    onToggle: controller.setEveningEnabled,
                    onTimeTap: () => _pickTime(
                      context,
                      controller.eveningTime.value,
                      controller.setEveningTime,
                    ),
                  )),
            ],
          ),
          FrostedSettingsCard(
            title: 'HUKAMNAMA ALERTS',
            children: [
              Obx(() => _SimpleTile(
                    icon: Icons.campaign_rounded,
                    title: 'Daily Hukamnama',
                    subtitle: 'Receive updates sent by the admin',
                    enabled: controller.kumnaamaEnabled.value,
                    onToggle: controller.setKumnaamaEnabled,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay current,
    Future<void> Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) await onPicked(picked);
  }
}

// ── Prayer reminder tile (toggle + tappable time) ────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.time,
    required this.enabled,
    required this.onToggle,
    required this.onTimeTap,
  });

  final IconData icon;
  final String title;
  final TimeOfDay time;
  final bool enabled;
  final Future<void> Function(bool) onToggle;
  final VoidCallback onTimeTap;

  String _label(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SacredSpacing.md,
        vertical: SacredSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SacredSpacing.sm),
            decoration: BoxDecoration(
              color: c.surfaceContainer,
              borderRadius: BorderRadius.circular(SacredRadius.def),
            ),
            child: Icon(icon, color: c.primaryAccent, size: 20),
          ),
          const SizedBox(width: SacredSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SacredTypography.bodyMd.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: enabled ? onTimeTap : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Every day at ${_label(time)}',
                        style: SacredTypography.bodySm.copyWith(
                          color: enabled
                              ? c.primaryAccent
                              : c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (enabled) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: c.primaryAccent.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: c.primaryAccent,
            activeTrackColor: c.primaryAccent.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ── Simple toggle tile (no time picker) ──────────────────────────────────────

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onToggle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final Future<void> Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SacredSpacing.md,
        vertical: SacredSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SacredSpacing.sm),
            decoration: BoxDecoration(
              color: c.surfaceContainer,
              borderRadius: BorderRadius.circular(SacredRadius.def),
            ),
            child: Icon(icon, color: c.primaryAccent, size: 20),
          ),
          const SizedBox(width: SacredSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SacredTypography.bodyMd.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: SacredTypography.bodySm
                      .copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: c.primaryAccent,
            activeTrackColor: c.primaryAccent.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ── Thin divider between tiles inside a card ─────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider({required this.c});
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: SacredSpacing.marginMobile,
      endIndent: SacredSpacing.marginMobile,
      color: c.borderGold.withValues(alpha: 0.1),
    );
  }
}
