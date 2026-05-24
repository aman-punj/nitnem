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

      return GestureDetector(
        onTap: () => _openPrayerPage(context, ctrl),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceContainerLowest,
            border: Border(
              top: BorderSide(
                color: c.primaryAccent.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: c.primaryAccent.withValues(alpha: 0.06),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SacredSpacing.gutter,
                vertical: SacredSpacing.base,
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
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SacredSpacing.sm),
                  GestureDetector(
                    onTap: ctrl.togglePlayback,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.primaryAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.primaryAccent.withValues(alpha: 0.25),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        ctrl.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: c.onPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.c});

  final String url;
  final SacredColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
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
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _FallbackIcon(c: c),
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
        size: 22,
        color: c.primaryAccent.withValues(alpha: 0.6),
      ),
    );
  }
}
