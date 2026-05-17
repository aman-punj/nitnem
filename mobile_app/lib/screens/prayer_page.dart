import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: SacredDsAppBar(
        title: title,
        appBarStyle: SacredTypography.headlineMd.copyWith(
          color: SacredColors.primaryAccent,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          // Mode Switcher in App Bar Actions
          Padding(
            padding: const EdgeInsets.only(right: SacredSpacing.base),
            child: Obx(() => SacredSegmentedControl<PrimaryMode>(
              segments: const {
                PrimaryMode.audio: 'Audio',
                PrimaryMode.focus: 'Focus',
              },
              selected: controller.primaryMode.value,
              onSelected: controller.setPrimaryMode,
              isSecondary: true, // Use secondary style for compact app bar fit
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
            final hasTimings = controller.hasTimings.value;
            final isAudioMode = controller.primaryMode.value == PrimaryMode.audio;

            // Calculate padding to ensure lines start near the top-middle
            // - Add top padding for initial centering
            // - Add bottom padding to allow scrolling last items to center
            final double verticalPadding = constraints.maxHeight * 0.45;

            return Column(
              children: [
                // Transcript Section
                Flexible(
                  child: ScrollablePositionedList.builder(
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
                      // Top flower (index 0)
                      if (index == 0) {
                        return _buildFlowerIcon(top: true);
                      }
                      // Bottom flower (index last)
                      if (index == controller.segments.length + 1) {
                        return _buildFlowerIcon(top: false);
                      }

                      // Adjust index (skip top flower)
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
                ),

                // Glassmorphic Player Section
                Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                  child: controller.primaryMode.value == PrimaryMode.audio
                      ? ClipRRect(
                    key: const ValueKey('audio_player'),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(SacredRadius.xl)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(SacredSpacing.md, SacredSpacing.marginMobile, SacredSpacing.md, SacredSpacing.lg),
                        decoration: BoxDecoration(
                          color: SacredColors.surfaceContainerLowest.withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(SacredRadius.xl)),
                          border: Border.all(
                            color: SacredColors.borderGold.withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SacredColors.primaryAccent.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress Bar
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                activeTrackColor: SacredColors.primaryAccent,
                                inactiveTrackColor: SacredColors.primaryAccent.withValues(alpha: 0.1),
                                thumbColor: SacredColors.primaryAccent,
                                overlayColor: SacredColors.primaryAccent.withValues(alpha: 0.1),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                trackShape: const RectangularSliderTrackShape(),
                              ),
                              child: Slider(
                                min: 0,
                                max: controller.totalDuration.value.inMilliseconds.toDouble(),
                                value: controller.currentPosition.value.inMilliseconds
                                    .clamp(0, controller.totalDuration.value.inMilliseconds)
                                    .toDouble(),
                                onChanged: (value) => controller.seekToWithDebounce(
                                    Duration(milliseconds: value.toInt())),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.xs),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.formatDuration(controller.currentPosition.value),
                                    style: SacredTypography.labelSm.copyWith(color: SacredColors.textSecondary),
                                  ),
                                  Text(
                                    controller.formatDuration(controller.totalDuration.value),
                                    style: SacredTypography.labelSm.copyWith(color: SacredColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: SacredSpacing.gutter),
                            // Main Controls
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay_10_rounded, color: SacredColors.textPrimary, size: 28),
                                      onPressed: controller.skipBackward,
                                    ),
                                    const SizedBox(width: SacredSpacing.xxl),
                                    GestureDetector(
                                      onTap: controller.togglePlayback,
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: SacredColors.primaryAccent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: SacredColors.primaryAccent.withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: Colors.black,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: SacredSpacing.xxl),
                                    IconButton(
                                      icon: const Icon(Icons.forward_10_rounded, color: SacredColors.textPrimary, size: 28),
                                      onPressed: controller.skipForward,
                                    ),
                                  ],
                                ),
                                // Speed Controller on the right
                                Positioned(
                                  right: 0,
                                  child: PopupMenuButton<double>(
                                    icon: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.base, vertical: SacredSpacing.xs),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: SacredColors.primaryAccent.withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(SacredRadius.def),
                                      ),
                                      child: Text(
                                        '${controller.playbackSpeed.value}x',
                                        style: SacredTypography.labelSm.copyWith(
                                          color: SacredColors.primaryAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    color: SacredColors.surfaceContainer,
                                    onSelected: controller.changePlaybackSpeed,
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 0.5, child: Text('0.5x', style: TextStyle(color: SacredColors.textPrimary))),
                                      PopupMenuItem(value: 0.75, child: Text('0.75x', style: TextStyle(color: SacredColors.textPrimary))),
                                      PopupMenuItem(value: 1.0, child: Text('1x', style: TextStyle(color: SacredColors.textPrimary))),
                                      PopupMenuItem(value: 1.25, child: Text('1.25x', style: TextStyle(color: SacredColors.textPrimary))),
                                      PopupMenuItem(value: 1.5, child: Text('1.5x', style: TextStyle(color: SacredColors.textPrimary))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(key: ValueKey('focus_spacer')),
                )),
              ],
            );
          },
        ));
      }),
    );
  }

  // Helper method for flower
  Widget _buildFlowerIcon({required bool top}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            top: top ? 0 : SacredSpacing.xl,
            bottom: top ? SacredSpacing.xl : 0,
        ),
        child: Icon(
          Icons.local_florist_rounded,
          size: 40,
          color: SacredColors.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
