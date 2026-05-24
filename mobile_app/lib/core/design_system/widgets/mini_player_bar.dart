import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/mini_player_controller.dart';
import '../../../screens/prayer_page.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MiniPlayerController>();
    final c = SacredColors.of(context);

    return Obx(() {
      if (!ctrl.isActive.value) return const SizedBox.shrink();

      final total = ctrl.totalDuration.value.inMilliseconds;
      final progress = total > 0
          ? (ctrl.position.value.inMilliseconds / total).clamp(0.0, 1.0)
          : 0.0;

      return GestureDetector(
        onTap: () => _openPrayerPage(context, ctrl),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceContainerLowest,
            border: Border(
              top: BorderSide(
                color: c.primaryAccent.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: c.primaryAccent.withValues(alpha: 0.08),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              _ProgressBar(progress: progress, c: c),

              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SacredSpacing.gutter,
                    SacredSpacing.sm,
                    SacredSpacing.gutter,
                    SacredSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _Thumbnail(url: ctrl.thumbnailUrl.value, c: c),
                      const SizedBox(width: SacredSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ctrl.prayerTitle.value,
                              style: SacredTypography.bodyMd.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ctrl.formatDuration(ctrl.position.value)}'
                              ' / '
                              '${ctrl.formatDuration(ctrl.totalDuration.value)}',
                              style: SacredTypography.meta.copyWith(
                                color: c.textSecondary.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SacredSpacing.sm),
                      _PlayPauseButton(ctrl: ctrl, c: c),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: ctrl.dismiss,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: c.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openPrayerPage(BuildContext context, MiniPlayerController ctrl) {
    final args = ctrl.navArgs;
    if (args == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PrayerPage(
          title: args.title,
          gurmukhiTitle: args.gurmukhiTitle,
          audioPath: args.audioPath,
          transcriptPath: args.transcriptPath,
          audioIsLocalFile: args.audioIsLocalFile,
          transcriptIsLocalFile: args.transcriptIsLocalFile,
          contentItem: args.contentItem,
          currentLang: args.currentLang,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.c});

  final double progress;
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: c.primaryAccent.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation<Color>(
          c.primaryAccent.withValues(alpha: 0.7),
        ),
        minHeight: 2,
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.ctrl, required this.c});

  final MiniPlayerController ctrl;
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ctrl.togglePlayback,
      behavior: HitTestBehavior.opaque,
      child: Obx(() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.primaryAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.primaryAccent.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          ctrl.isPlaying.value
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: c.onPrimary,
          size: 22,
        ),
      )),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.c});

  final String url;
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SacredRadius.sm),
        color: c.surfaceContainerLow,
        border: Border.all(
          color: c.primaryAccent.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => _FallbackIcon(c: c),
              errorWidget: (_, __, ___) => _FallbackIcon(c: c),
            )
          : _FallbackIcon(c: c),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.c});
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.spa_rounded,
        size: 20,
        color: c.primaryAccent.withValues(alpha: 0.6),
      ),
    );
  }
}
