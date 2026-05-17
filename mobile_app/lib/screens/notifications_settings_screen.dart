import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/notification_settings_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/services/notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> with WidgetsBindingObserver {
  NotificationSettingsController get controller =>
      Get.find<NotificationSettingsController>();
  NotificationService get _svc => Get.find<NotificationService>();

  bool _notificationsEnabled = true;
  bool _canScheduleExact = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notifOk = await _svc.areNotificationsEnabled();
    final alarmOk = await _svc.canScheduleExact();
    if (mounted) {
      setState(() {
        _notificationsEnabled = notifOk;
        _canScheduleExact = alarmOk;
      });
    }
  }

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
          if (!_notificationsEnabled)
            _PermissionBanner(
              icon: Icons.notifications_off_rounded,
              title: 'Notifications Disabled',
              body:
                  'Reminders cannot be delivered. Enable notifications for Nitnem in your device settings.',
              actionLabel: 'Open Settings',
              onAction: _svc.openAppSettings,
            ),
          if (_notificationsEnabled && !_canScheduleExact)
            _PermissionBanner(
              icon: Icons.alarm_off_rounded,
              title: 'Precise Reminders Limited',
              body:
                  'Exact alarm permission is needed to deliver reminders at the exact time you set.',
              actionLabel: 'Enable Alarms',
              onAction: _svc.openAlarmSettings,
            ),
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
          FrostedSettingsCard(
            title: 'CUSTOM REMINDERS',
            children: [
              Obx(() {
                final reminders = controller.customReminders;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reminders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SacredSpacing.md,
                          vertical: SacredSpacing.base,
                        ),
                        child: Text(
                          'No custom reminders yet',
                          style: SacredTypography.bodySm
                              .copyWith(color: c.textSecondary),
                        ),
                      ),
                    ...reminders.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final r = entry.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (idx > 0) _Divider(c: c),
                          _CustomReminderTile(
                            reminder: r,
                            onToggle: () =>
                                controller.toggleCustomReminder(r.id),
                            onDelete: () =>
                                controller.deleteCustomReminder(r.id),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: SacredSpacing.xs),
                    _AddReminderButton(
                      onTap: () => _showCreateSheet(context),
                    ),
                    const SizedBox(height: SacredSpacing.sm),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateReminderSheet(controller: controller),
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

// ── Permission banner ─────────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: SacredSpacing.md),
      padding: const EdgeInsets.all(SacredSpacing.md),
      decoration: BoxDecoration(
        color: c.primaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SacredRadius.md),
        border: Border.all(color: c.primaryAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c.primaryAccent, size: 22),
          const SizedBox(width: SacredSpacing.sm),
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
                const SizedBox(height: 4),
                Text(
                  body,
                  style: SacredTypography.bodySm.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: SacredSpacing.sm),
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: SacredTypography.labelSm.copyWith(
                      color: c.primaryAccent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        vertical: 14,
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
        vertical: 14,
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

// ── Custom reminder tile ──────────────────────────────────────────────────────

class _CustomReminderTile extends StatelessWidget {
  const _CustomReminderTile({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  final CustomReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

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
            child: Icon(Icons.alarm_rounded, color: c.primaryAccent, size: 20),
          ),
          const SizedBox(width: SacredSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: SacredTypography.bodyMd.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Every day at ${_label(reminder.time)}',
                  style: SacredTypography.bodySm
                      .copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.enabled,
            onChanged: (_) => onToggle(),
            activeThumbColor: c.primaryAccent,
            activeTrackColor: c.primaryAccent.withValues(alpha: 0.2),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: c.textSecondary.withValues(alpha: 0.6), size: 20),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ── Add reminder button ───────────────────────────────────────────────────────

class _AddReminderButton extends StatelessWidget {
  const _AddReminderButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: SacredSpacing.md),
        padding: const EdgeInsets.symmetric(vertical: SacredSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(
            color: c.primaryAccent.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(SacredRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: c.primaryAccent, size: 18),
            const SizedBox(width: SacredSpacing.xs),
            Text(
              'Add Reminder',
              style: SacredTypography.bodyMd.copyWith(
                color: c.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create reminder bottom sheet ─────────────────────────────────────────────

class _CreateReminderSheet extends StatefulWidget {
  const _CreateReminderSheet({required this.controller});
  final NotificationSettingsController controller;

  @override
  State<_CreateReminderSheet> createState() => _CreateReminderSheetState();
}

class _CreateReminderSheetState extends State<_CreateReminderSheet> {
  final _titleController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _label(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    await widget.controller.addCustomReminder(title, _time);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceContainerLowest,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(SacredRadius.xl)),
          border: Border(
            top: BorderSide(color: c.primaryAccent.withValues(alpha: 0.12), width: 0.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          SacredSpacing.marginMobile,
          SacredSpacing.md,
          SacredSpacing.marginMobile,
          SacredSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(SacredRadius.full),
                ),
              ),
            ),
            const SizedBox(height: SacredSpacing.md),
            Text(
              'New Reminder',
              style: SacredTypography.headlineMd.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SacredSpacing.md),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: SacredTypography.bodyMd.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Reminder title',
                hintStyle: SacredTypography.bodyMd.copyWith(color: c.textSecondary),
                filled: true,
                fillColor: c.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SacredRadius.md),
                  borderSide: BorderSide(color: c.borderGold.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SacredRadius.md),
                  borderSide: BorderSide(color: c.borderGold.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SacredRadius.md),
                  borderSide: BorderSide(color: c.primaryAccent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: SacredSpacing.md),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SacredSpacing.md,
                  vertical: SacredSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: c.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(SacredRadius.md),
                  border: Border.all(color: c.borderGold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: c.primaryAccent, size: 20),
                    const SizedBox(width: SacredSpacing.sm),
                    Text(
                      _label(_time),
                      style: SacredTypography.bodyMd.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'tap to change',
                      style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SacredSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: c.primaryAccent,
                  foregroundColor: c.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: SacredSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SacredRadius.md),
                  ),
                ),
                child: Text(
                  _saving ? 'Saving…' : 'Create Reminder',
                  style: SacredTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
