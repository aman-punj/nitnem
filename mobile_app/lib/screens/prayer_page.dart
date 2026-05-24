import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/mini_player_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/focus_transcript_line.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_loader.dart';
import 'package:nitnem/core/design_system/widgets/sacred_segmented_control.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/prayer_controller.dart';
import '../models/content_item.dart';
import '../services/local_content_service.dart';
import '../services/transcript_sync_engine.dart';
import '../services/transcript_sync_service.dart';

class PrayerPage extends StatelessWidget {
  final String title;
  final String? gurmukhiTitle;
  final String audioPath;
  final String transcriptPath;
  final bool audioIsLocalFile;
  final bool transcriptIsLocalFile;
  final ContentItem? contentItem;
  final String? currentLang;

  const PrayerPage({
    super.key,
    required this.title,
    this.gurmukhiTitle,
    required this.audioPath,
    required this.transcriptPath,
    this.audioIsLocalFile = false,
    this.transcriptIsLocalFile = false,
    this.contentItem,
    this.currentLang,
  });

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final controller = Get.put<PrayerController>(
      PrayerController(
        transcriptSyncEngine: const TranscriptSyncEngine(),
        syncService: Get.find<TranscriptSyncService>(),
        localContentService: Get.find<LocalContentService>(),
      ),
      tag: title,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prayerTitle.value = title;
      controller.loadContent(
        audioPath: audioPath,
        transcriptPath: transcriptPath,
        audioIsLocalFile: audioIsLocalFile,
        transcriptIsLocalFile: transcriptIsLocalFile,
        item: contentItem,
        currentLang: currentLang,
      );
    });

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: SacredDsAppBar(
        title: title,
        appBarStyle: SacredTypography.headlineMd.copyWith(
          color: c.primaryAccent,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SacredSpacing.base),
            child: Obx(() => SacredSegmentedControl<PrimaryMode>(
              segments: const {
                PrimaryMode.audio: 'Audio',
                PrimaryMode.focus: 'Focus',
              },
              selected: controller.primaryMode.value,
              onSelected: controller.setPrimaryMode,
              isSecondary: true,
            )),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SacredLoader(text: controller.loadingMessage.value);
        }

        return SafeArea(child: LayoutBuilder(
          builder: (context, constraints) {
            final double verticalPadding = constraints.maxHeight * 0.45;

            return Column(
              children: [
                Flexible(
                  child: Stack(
                    children: [
                      ScrollablePositionedList.builder(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                    itemCount: controller.segments.length + 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SacredSpacing.md,
                    ).copyWith(
                      top: verticalPadding,
                      bottom: verticalPadding,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildFlowerIcon(top: true, c: c);
                      if (index == controller.segments.length + 1) {
                        return _buildFlowerIcon(top: false, c: c);
                      }

                      final segmentIndex = index - 1;
                      final segment = controller.segments[segmentIndex];

                      return Obx(() {
                        final isPlaybackHighlighted =
                            controller.primaryMode.value == PrimaryMode.audio &&
                                segmentIndex == controller.currentSegmentIndex.value;

                        final isFocusHighlighted =
                            controller.primaryMode.value == PrimaryMode.focus &&
                                segmentIndex == controller.centerFocusIndex.value;

                        return GestureDetector(
                          onTap: () {
                            controller.showHeader();
                            controller.onTapSegment(segmentIndex);
                          },
                          onDoubleTap: () {
                            controller.showHeader();
                            controller.onDoubleTapSegment(segment, segmentIndex);
                          },
                          child: FocusTranscriptLine(
                            text: segment.forLanguage(
                              controller.languageCode.value,
                              enableHindi: controller.enableHindi.value,
                              enableEnglish: controller.enableEnglish.value,
                            ),
                            isPlaybackHighlighted: isPlaybackHighlighted,
                            isFocusHighlighted: isFocusHighlighted,
                            isFocusMode: controller.primaryMode.value == PrimaryMode.focus,
                          ),
                        );
                      });
                    },
                      ),
                      Obx(() => controller.primaryMode.value == PrimaryMode.audio
                          ? Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  height: 72,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        c.backgroundPrimary.withValues(alpha: 0),
                                        c.backgroundPrimary.withValues(alpha: 0.9),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),

                // Minimal clean player panel
                Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                  child: controller.primaryMode.value == PrimaryMode.audio
                      ? _buildPlayer(context, c, controller)
                      : const SizedBox.shrink(key: ValueKey('focus_spacer')),
                )),
              ],
            );
          },
        ));
      }),
    );
  }

  Widget _buildPlayer(BuildContext context, SacredColors c, PrayerController controller) {
    return Container(
      key: const ValueKey('audio_player'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(SacredRadius.lg)),
        border: Border(
          top: BorderSide(color: c.primaryAccent.withValues(alpha: 0.12), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: c.primaryAccent.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SacredSpacing.marginMobile,
            SacredSpacing.sm,
            SacredSpacing.marginMobile,
            SacredSpacing.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress slider — inherits SliderTheme from ThemeData
              Slider(
                min: 0,
                max: controller.totalDuration.value.inMilliseconds.toDouble(),
                value: controller.currentPosition.value.inMilliseconds
                    .clamp(0, controller.totalDuration.value.inMilliseconds)
                    .toDouble(),
                onChanged: (value) => controller.seekToWithDebounce(
                    Duration(milliseconds: value.toInt())),
              ),

              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.formatDuration(controller.currentPosition.value),
                      style: SacredTypography.labelSm.copyWith(color: c.textSecondary),
                    ),
                    Text(
                      controller.formatDuration(controller.totalDuration.value),
                      style: SacredTypography.labelSm.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SacredSpacing.sm),

              // Playback controls
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconBtn(Icons.replay_10_rounded, c.textPrimary, 26, controller.skipBackward),
                      const SizedBox(width: SacredSpacing.xxl),
                      _playPauseButton(c, controller),
                      const SizedBox(width: SacredSpacing.xxl),
                      _iconBtn(Icons.forward_10_rounded, c.textPrimary, 26, controller.skipForward),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    child: _buildLockButton(c),
                  ),
                  Positioned(
                    right: 0,
                    child: Obx(() => _buildSpeedButton(context, c, controller)),
                  ),
                ],
              ),
              const SizedBox(height: SacredSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, SacredColors c, PrayerController controller) {
    return PopupMenuButton<double>(
      padding: EdgeInsets.zero,
      color: c.surfaceContainer,
      onSelected: controller.changePlaybackSpeed,
      itemBuilder: (context) => [
        PopupMenuItem(value: 0.75, child: Text('0.75x', style: TextStyle(color: c.textPrimary))),
        PopupMenuItem(value: 1.0,  child: Text('1x',    style: TextStyle(color: c.textPrimary))),
        PopupMenuItem(value: 1.25, child: Text('1.25x', style: TextStyle(color: c.textPrimary))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SacredSpacing.sm,
          vertical: SacredSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: c.primaryAccent.withValues(alpha: 0.25), width: 0.5),
          borderRadius: BorderRadius.circular(SacredRadius.full),
        ),
        child: Text(
          '${controller.playbackSpeed.value}x',
          style: SacredTypography.meta.copyWith(
            color: c.primaryAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLockButton(SacredColors c) {
    if (!Get.isRegistered<MiniPlayerController>()) return const SizedBox.shrink();
    final miniCtrl = Get.find<MiniPlayerController>();
    return Obx(() {
      final allowed = miniCtrl.allowBackgroundPlay.value;
      return IconButton(
        icon: Icon(
          allowed ? Icons.lock_open_rounded : Icons.lock_rounded,
          size: 20,
          color: allowed ? c.primaryAccent : c.textSecondary.withValues(alpha: 0.5),
        ),
        tooltip: allowed ? 'Plays when locked' : 'Pauses when locked',
        onPressed: miniCtrl.toggleBackgroundPlay,
        visualDensity: VisualDensity.compact,
      );
    });
  }

  Widget _playPauseButton(SacredColors c, PrayerController controller) {
    return GestureDetector(
      onTap: controller.togglePlayback,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: c.primaryAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.primaryAccent.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          controller.isPlaying.value
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: c.onPrimary,
          size: 34,
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, double size, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildFlowerIcon({required bool top, required SacredColors c}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: top ? 0 : SacredSpacing.xl,
          bottom: top ? SacredSpacing.xl : 0,
        ),
        child: Icon(
          Icons.local_florist_rounded,
          size: 36,
          color: c.primaryAccent.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
