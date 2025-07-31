import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'dart:async';
import 'package:nitnem/utils/gradient_scaffold.dart';

/// Model for a single transcript segment
class TranscriptSegment {
  final double start;
  final double end;
  final String text;

  TranscriptSegment({required this.start, required this.end, required this.text});

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: json['start']?.toDouble() ?? 0.0,
      end: json['end']?.toDouble() ?? 0.0,
      text: json['text'] ?? '',
    );
  }
}

/// GetX Controller for Prayer Page
class PrayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  // Observables
  final RxList<TranscriptSegment> segments = <TranscriptSegment>[].obs;
  final RxInt currentSegmentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTextOnlyMode = false.obs;
  final RxBool isUserScrolling = false.obs;
  final RxBool isUserSeeking = false.obs; // Track slider interactions separately
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  // Add configuration options for fine-tuning
  final RxDouble playbackSpeed = 1.0.obs;
  final RxDouble scrollAlignment = 0.3.obs; // Adjustable alignment (0.0 = top, 0.5 = center, 1.0 = bottom)
  final RxInt scrollAnimationDuration = 800.obs; // Adjustable animation duration in ms
  final RxBool useAlternativeScroll = false.obs; // Toggle between scroll methods
  final RxBool enableScrollDebug = true.obs; // Toggle debug prints

  // Controllers
  late ScrollController scrollController;
  final Map<int, GlobalKey> segmentKeys = {};

  // Debouncer for slider
  Timer? _sliderDebounceTimer;
  Duration? _pendingSeekPosition;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _setupAudioListeners();
  }

  void _createSegmentKeys() {
    segmentKeys.clear();
    for (int i = 0; i < segments.length; i++) {
      segmentKeys[i] = GlobalKey();
    }
  }

  void _setupAudioListeners() {
    // Position stream
    _player.positionStream.listen((position) {
      currentPosition.value = position;
      if (!isUserScrolling.value) {
        _updateCurrentSegment(position);
      }
    });

    // Duration stream
    _player.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });

    // Playing state stream
    _player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });
  }

  Future<void> loadContent(String audioPath, String transcriptPath) async {
    try {
      isLoading.value = true;

      // Load transcript
      final jsonStr = await rootBundle.loadString(transcriptPath);
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      final List<dynamic> segmentList = jsonData['segments'] ?? [];
      segments.value = segmentList.map((s) => TranscriptSegment.fromJson(s)).toList();

      // Create keys for each segment after loading
      _createSegmentKeys();

      // Load audio
      await _player.setAsset(audioPath);

      isLoading.value = false;
    } catch (e) {
      print('Error loading content: $e');
      isLoading.value = false;
    }
  }

  void _updateCurrentSegment(Duration position) {
    // Skip updates during active seeking to prevent conflicts
    if (isUserSeeking.value) {
      return;
    }

    final seconds = position.inMilliseconds / 1000.0;
    final index = segments.indexWhere((s) => seconds >= s.start && seconds <= s.end);

    if (index != currentSegmentIndex.value && index != -1) {
      if (enableScrollDebug.value) {
        print('Natural segment change from ${currentSegmentIndex.value} to $index at ${formatDuration(position)}');
      }

      currentSegmentIndex.value = index;
      // Auto-scroll should work UNLESS user is manually scrolling the lyrics
      if (!isUserScrolling.value) {
        if (useAlternativeScroll.value) {
          _autoScrollToCurrentSegmentAlternative();
        } else {
          _autoScrollToCurrentSegment();
        }
      }
    }
  }

  void _autoScrollToCurrentSegment() {
    if (currentSegmentIndex.value >= 0 &&
        scrollController.hasClients &&
        segmentKeys.containsKey(currentSegmentIndex.value)) {

      final key = segmentKeys[currentSegmentIndex.value];
      if (key?.currentContext != null) {
        // Debug: Print current segment info
        print('Auto-scrolling to segment ${currentSegmentIndex.value}: "${segments[currentSegmentIndex.value].text.substring(0, 50)}..."');

        // Use Scrollable.ensureVisible for accurate positioning
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.3, // Position segment at 30% from top of viewport
        ).catchError((e) {
          print('Error scrolling to segment: $e');
        });
      } else {
        print('Warning: Context not found for segment ${currentSegmentIndex.value}');
      }
    }
  }

  // Alternative scrolling method if ensureVisible doesn't work well
  void _autoScrollToCurrentSegmentAlternative() {
    if (currentSegmentIndex.value >= 0 && scrollController.hasClients) {
      try {
        final key = segmentKeys[currentSegmentIndex.value];
        if (key?.currentContext != null) {
          final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          final scrollPosition = scrollController.position;

          // Calculate target scroll offset
          final targetOffset = scrollController.offset + position.dy - 200; // 200px from top

          print('Scrolling to calculated position: $targetOffset');

          scrollController.animateTo(
            targetOffset.clamp(0.0, scrollPosition.maxScrollExtent),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      } catch (e) {
        print('Error in alternative scroll method: $e');
        // Fallback to approximate positioning
        _fallbackScroll();
      }
    }
  }

  void _fallbackScroll() {
    if (currentSegmentIndex.value >= 0 && scrollController.hasClients) {
      // Estimate position based on average segment height
      const estimatedHeight = 100.0; // Adjust based on your typical segment height
      final targetOffset = currentSegmentIndex.value * estimatedHeight;

      print('Using fallback scroll to estimated position: $targetOffset');

      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void seekTo(Duration position) {
    if (enableScrollDebug.value) {
      print('Immediate seek to: ${formatDuration(position)}');
    }
    _player.seek(position);
  }

  void seekToWithDebounce(Duration position) {
    // Store the pending position
    _pendingSeekPosition = position;
    isUserSeeking.value = true;

    // Cancel previous timer
    _sliderDebounceTimer?.cancel();

    // Immediate seek for responsive UI (no debounce for audio)
    seekTo(position);

    // Debounced auto-scroll calculation
    _sliderDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_pendingSeekPosition != null) {
        _handleDebouncedSeek(_pendingSeekPosition!);
        _pendingSeekPosition = null;
      }
    });
  }

  void _handleDebouncedSeek(Duration position) {
    if (enableScrollDebug.value) {
      print('Debounced seek completed to: ${formatDuration(position)}');
    }

    // Force update current segment based on the final position
    final seconds = position.inMilliseconds / 1000.0;
    final newIndex = segments.indexWhere((s) => seconds >= s.start && seconds <= s.end);

    if (newIndex != -1 && newIndex != currentSegmentIndex.value) {
      if (enableScrollDebug.value) {
        print('Force updating segment from ${currentSegmentIndex.value} to $newIndex');
      }

      currentSegmentIndex.value = newIndex;

      // Force auto-scroll after seek
      Future.delayed(const Duration(milliseconds: 100), () {
        if (useAlternativeScroll.value) {
          _autoScrollToCurrentSegmentAlternative();
        } else {
          _autoScrollToCurrentSegment();
        }

        // Clear seeking flag
        isUserSeeking.value = false;
        if (enableScrollDebug.value) {
          print('Seek auto-scroll completed, seeking flag cleared');
        }
      });
    } else {
      // Just clear the seeking flag if no segment change needed
      isUserSeeking.value = false;
    }
  }

  void skipForward() {
    final newPosition = currentPosition.value + const Duration(seconds: 10);
    seekToWithDebounce(newPosition);
  }

  void skipBackward() {
    final newPosition = currentPosition.value - const Duration(seconds: 10);
    seekToWithDebounce(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    _player.setSpeed(speed);
  }

  void toggleTextOnlyMode() {
    isTextOnlyMode.value = !isTextOnlyMode.value;
  }

  void onUserScrollStart() {
    isUserScrolling.value = true;
    if (enableScrollDebug.value) {
      print('User started scrolling lyrics manually');
    }
  }

  void onUserScrollEnd() {
    if (enableScrollDebug.value) {
      print('User stopped scrolling, will resume auto-scroll in 3 seconds');
    }
    // Delay before resuming auto-scroll (increased from 2 to 3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      isUserScrolling.value = false;
      if (enableScrollDebug.value) {
        print('Auto-scroll resumed');
      }
    });
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    _sliderDebounceTimer?.cancel();
    scrollController.dispose();
    _player.dispose();
    super.onClose();
  }
}

/// Enhanced Prayer Page with Sacred Theme
class PrayerPage extends StatelessWidget {
  final String title;
  final String? gurmukhiTitle;
  final String audioAssetPath;
  final String transcriptAssetPath;

  const PrayerPage({
    super.key,
    required this.title,
    this.gurmukhiTitle,
    required this.audioAssetPath,
    required this.transcriptAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerController());

    // Initialize content loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadContent(audioAssetPath, transcriptAssetPath);
    });

    return GradientScaffold(
      showKhandaSymbol: true,
      appBar: SacredAppBar(
        title: title,
        // gurmukhiTitle: gurmukhiTitle,
        actions: [
          // Text-only mode toggle
          Obx(() => IconButton(
            icon: Icon(
              controller.isTextOnlyMode.value
                  ? Icons.headphones
                  : Icons.text_fields,
            ),
            onPressed: controller.toggleTextOnlyMode,
            tooltip: controller.isTextOnlyMode.value
                ? 'Enable Audio Mode'
                : 'Text Only Mode',
          )),

          // Playback speed
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed),
            onSelected: controller.changePlaybackSpeed,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.5, child: Text('0.5x')),
              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
              const PopupMenuItem(value: 1.0, child: Text('1x')),
              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading sacred text...',
                  style: TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Debug panel (remove in production)
            // if (controller.enableScrollDebug.value)
            //   Container(
            //     margin: const EdgeInsets.all(16),
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.7),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text(
            //           'Debug Info:',
            //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //         ),
            //         Obx(() => Text(
            //           'Current Segment: ${controller.currentSegmentIndex.value}',
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         )),
            //         Obx(() => Text(
            //           'User Scrolling: ${controller.isUserScrolling.value}',
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         )),
            //         Obx(() => Text(
            //           'User Seeking: ${controller.isUserSeeking.value}',
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         )),
            //         Obx(() => Text(
            //           'Total Segments: ${controller.segments.length}',
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         )),
            //         Row(
            //           children: [
            //             Text('Alt Scroll: ', style: TextStyle(color: Colors.white, fontSize: 12)),
            //             Obx(() => Switch(
            //               value: controller.useAlternativeScroll.value,
            //               onChanged: (value) => controller.useAlternativeScroll.value = value,
            //               activeColor: Color(0xFFD4AF37),
            //             )),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF7).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE6D3A3).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4C19C).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: NotificationListener<ScrollStartNotification>(
                  onNotification: (notification) {
                    controller.onUserScrollStart();
                    return false;
                  },
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (notification) {
                      controller.onUserScrollEnd();
                      return false;
                    },
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.segments.length,
                      itemBuilder: (context, index) {
                        final segment = controller.segments[index];
                        final isHighlighted = index == controller.currentSegmentIndex.value;

                        return GestureDetector(
                          key: controller.segmentKeys[index], // Add the key here
                          onTap: () {
                            // Seek to this segment when tapped
                            final seekPosition = Duration(
                              milliseconds: (segment.start * 1000).round(),
                            );
                            controller.seekToWithDebounce(seekPosition);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isHighlighted
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFB8860B),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: isHighlighted
                                  ? Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              )
                                  : null,
                            ),
                            child: Text(
                              segment.text,
                              style: TextStyle(
                                color: isHighlighted
                                    ? Colors.white
                                    : const Color(0xFF8B4513),
                                fontWeight: isHighlighted
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 18,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Audio Controls (hidden in text-only mode)
            if (!controller.isTextOnlyMode.value) ...[
              // Progress Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFD4AF37),
                        inactiveTrackColor: const Color(0xFFE6D3A3).withOpacity(0.3),
                        thumbColor: const Color(0xFFB8860B),
                        overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        min: 0,
                        max: controller.totalDuration.value.inMilliseconds.toDouble(),
                        value: controller.currentPosition.value.inMilliseconds
                            .clamp(0, controller.totalDuration.value.inMilliseconds)
                            .toDouble(),
                        onChangeStart: (value) {
                          // Mark that user started seeking (prevents natural updates)
                          controller.isUserSeeking.value = true;
                        },
                        onChanged: (value) {
                          // Use debounced seek for slider interactions
                          controller.seekToWithDebounce(Duration(milliseconds: value.toInt()));
                        },
                        onChangeEnd: (value) {
                          // Final seek with debounce
                          controller.seekToWithDebounce(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),

                    // Time labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.formatDuration(controller.currentPosition.value),
                            style: const TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Obx(() => Text(
                            '${controller.playbackSpeed.value}x',
                            style: const TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                          Text(
                            controller.formatDuration(controller.totalDuration.value),
                            style: const TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Control Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Skip backward
                    _buildControlButton(
                      icon: Icons.replay_10,
                      onPressed: controller.skipBackward,
                      size: 32,
                    ),

                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFB8860B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4C19C).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 36,
                          color: Colors.white,
                        ),
                        onPressed: controller.togglePlayback,
                        iconSize: 36,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    // Skip forward
                    _buildControlButton(
                      icon: Icons.forward_10,
                      onPressed: controller.skipForward,
                      size: 32,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6D3A3).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4C19C).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size,
          color: const Color(0xFF8B4513),
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}