import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/prayer_controller.dart';
import '../services/transcript_sync_engine.dart';
import '../utils/gradient_scaffold.dart';

class PrayerPage extends StatelessWidget {
  final String title;
  final String? gurmukhiTitle;
  final String audioPath;
  final String transcriptPath;
  final bool audioIsLocalFile;
  final bool transcriptIsLocalFile;

  const PrayerPage({
    super.key,
    required this.title,
    this.gurmukhiTitle,
    required this.audioPath,
    required this.transcriptPath,
    this.audioIsLocalFile = false,
    this.transcriptIsLocalFile = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PrayerController(transcriptSyncEngine: const TranscriptSyncEngine()),
      tag: title,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadContent(
        audioPath: audioPath,
        transcriptPath: transcriptPath,
        audioIsLocalFile: audioIsLocalFile,
        transcriptIsLocalFile: transcriptIsLocalFile,
      );
    });

    return GradientScaffold(
      showKhandaSymbol: true,
      appBar: SacredAppBar(
        title: title,
        actions: [
          Obx(() => IconButton(
                icon: Icon(controller.isTextOnlyMode.value
                    ? Icons.headphones
                    : Icons.text_fields),
                onPressed: controller.toggleTextOnlyMode,
              )),
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed),
            onSelected: controller.changePlaybackSpeed,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0.5, child: Text('0.5x')),
              PopupMenuItem(value: 0.75, child: Text('0.75x')),
              PopupMenuItem(value: 1.0, child: Text('1x')),
              PopupMenuItem(value: 1.25, child: Text('1.25x')),
              PopupMenuItem(value: 1.5, child: Text('1.5x')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        return Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF7).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ScrollablePositionedList.builder(
                  itemScrollController: controller.itemScrollController,
                  itemPositionsListener: controller.itemPositionsListener,
                  itemCount: controller.segments.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    final segment = controller.segments[index];
                    final isHighlighted =
                        index == controller.currentSegmentIndex.value;
                    return GestureDetector(
                      onTap: () => controller.onTapSegment(segment),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isHighlighted
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFB8860B)
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          segment.forLanguage(
                            controller.languageCode.value,
                            enableHindi: controller.enableHindi.value,
                            enableEnglish: controller.enableEnglish.value,
                          ),
                          style: TextStyle(
                            color: isHighlighted
                                ? Colors.white
                                : const Color(0xFF8B4513),
                            fontWeight: isHighlighted
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 18,
                            height: 1.6,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (!controller.isTextOnlyMode.value) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(controller
                        .formatDuration(controller.currentPosition.value)),
                    Obx(() => Text('${controller.playbackSpeed.value}x')),
                    Text(controller
                        .formatDuration(controller.totalDuration.value)),
                  ],
                ),
              ),
              SafeArea(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: controller.skipBackward),
                  IconButton(
                    icon: Icon(controller.isPlaying.value
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: controller.togglePlayback,
                  ),
                  IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: controller.skipForward),
                ],
              )),
              const SizedBox(height: 16),
            ],
          ],
        );
      }),
    );
  }
}
