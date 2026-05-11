import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/widgets/focus_transcript_line.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_loader.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/prayer_controller.dart';
import '../models/content_item.dart';
import '../services/transcript_sync_engine.dart';
import '../utils/gradient_scaffold.dart';

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
    final controller = Get.put(
      PrayerController(
        transcriptSyncEngine: const TranscriptSyncEngine(),
        syncService: Get.find(),
        localContentService: Get.find(),
      ),
      tag: title,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadContent(
        audioPath: audioPath,
        transcriptPath: transcriptPath,
        audioIsLocalFile: audioIsLocalFile,
        transcriptIsLocalFile: transcriptIsLocalFile,
        item: contentItem,
        currentLang: currentLang,
      );
    });

    return GradientScaffold(
      showKhandaSymbol: false,
      appBar: SacredDsAppBar(
        title: title,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isFocusReadingMode.value
                      ? Icons.center_focus_strong_rounded
                      : Icons.center_focus_weak_rounded,
                  color: SacredColors.primaryAccent,
                ),
                onPressed: controller.toggleFocusReadingMode,
                tooltip: 'Focus Reading Mode',
              )),
          Obx(() => IconButton(
                icon: Icon(
                  controller.isTextOnlyMode.value
                      ? Icons.headphones_rounded
                      : Icons.text_fields_rounded,
                  color: SacredColors.primaryAccent,
                ),
                onPressed: controller.toggleTextOnlyMode,
              )),
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed_rounded, color: SacredColors.primaryAccent),
            color: SacredColors.surfacePrimary,
            onSelected: controller.changePlaybackSpeed,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0.5, child: Text('0.5x', style: TextStyle(color: SacredColors.textPrimary))),
              PopupMenuItem(value: 0.75, child: Text('0.75x', style: TextStyle(color: SacredColors.textPrimary))),
              PopupMenuItem(value: 1.0, child: Text('1x', style: TextStyle(color: SacredColors.textPrimary))),
              PopupMenuItem(value: 1.25, child: Text('1.25x', style: TextStyle(color: SacredColors.textPrimary))),
              PopupMenuItem(value: 1.5, child: Text('1.5x', style: TextStyle(color: SacredColors.textPrimary))),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SacredLoader(text: controller.loadingMessage.value);
        }

        return Column(
          children: [
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: controller.itemScrollController,
                itemPositionsListener: controller.itemPositionsListener,
                itemCount: controller.segments.length,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                itemBuilder: (context, index) {
                  final segment = controller.segments[index];
                  
                  final isPlaybackHighlighted =
                      index == controller.currentSegmentIndex.value;
                  final isFocusHighlighted = 
                      controller.isFocusReadingMode.value && index == controller.centerFocusIndex.value;
                  
                  return GestureDetector(
                    onTap: () => controller.onTapSegment(index),
                    onDoubleTap: () => controller.onDoubleTapSegment(segment, index),
                    child: FocusTranscriptLine(
                      text: segment.forLanguage(
                        controller.languageCode.value,
                        enableHindi: controller.enableHindi.value,
                        enableEnglish: controller.enableEnglish.value,
                      ),
                      isPlaybackHighlighted: isPlaybackHighlighted,
                      isFocusHighlighted: isFocusHighlighted,
                      isFocusMode: controller.isFocusReadingMode.value,
                    ),
                  );
                },
              ),
            ),
            if (!controller.isTextOnlyMode.value) ...[
              // Audio Control Bar (Premium dark surface)
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: SacredColors.backgroundBlack.withValues(alpha: 0.8),
                  border: const Border(
                    top: BorderSide(color: SacredColors.borderGold, width: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          activeTrackColor: SacredColors.primaryAccent,
                          inactiveTrackColor: SacredColors.borderGold.withValues(alpha: 0.2),
                          thumbColor: SacredColors.primaryAccent,
                          overlayColor: SacredColors.primaryAccent.withValues(alpha: 0.1),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.formatDuration(controller.currentPosition.value),
                            style: const TextStyle(color: SacredColors.textSecondary, fontSize: 12),
                          ),
                          Obx(() => Text(
                            '${controller.playbackSpeed.value}x',
                            style: const TextStyle(color: SacredColors.primaryAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          )),
                          Text(
                            controller.formatDuration(controller.totalDuration.value),
                            style: const TextStyle(color: SacredColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, color: SacredColors.textPrimary, size: 28),
                          onPressed: controller.skipBackward,
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: SacredColors.primaryAccent,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: IconButton(
                            icon: Icon(
                              controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                            onPressed: controller.togglePlayback,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: SacredColors.textPrimary, size: 28),
                          onPressed: controller.skipForward,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
