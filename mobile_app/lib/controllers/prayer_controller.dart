import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/transcript_segment.dart';
import '../services/transcript_parser.dart';
import '../services/transcript_sync_engine.dart';

enum ReadingMode { synced, audioOnlyText, textOnly }

class PrayerController extends GetxController {
  PrayerController({required this.transcriptSyncEngine});

  final TranscriptSyncEngine transcriptSyncEngine;
  final AudioPlayer _player = AudioPlayer();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final RxList<TranscriptSegment> segments = <TranscriptSegment>[].obs;
  final RxInt currentSegmentIndex = (-1).obs;
  final RxInt centerFocusIndex = (-1).obs;
  final RxInt selectedIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTextOnlyMode = false.obs;
  final RxBool isFocusReadingMode = false.obs;
  final RxBool isUserSeeking = false.obs;
  final RxBool enableHindi = false.obs;
  final RxBool enableEnglish = false.obs;
  final RxString languageCode = 'pn'.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;
  final Rx<ReadingMode> readingMode = ReadingMode.synced.obs;

  Timer? _seekDebounce;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    _player.positionStream.listen((position) {
      currentPosition.value = position;
      if (!isUserSeeking.value && readingMode.value == ReadingMode.synced) {
        _updateCurrentSegment(position);
      }
    });
    _player.durationStream.listen((duration) {
      if (duration != null) totalDuration.value = duration;
    });
    _player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });

    itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    if (isFocusReadingMode.value) {
      _updateCenterFocusIndex();
    }
  }

  void _updateCenterFocusIndex() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    double minDistance = 1.0;
    int closestIndex = -1;

    for (final position in positions) {
      final center = (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
      final distance = (center - 0.5).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = position.index;
      }
    }

    if (closestIndex != -1 && closestIndex != centerFocusIndex.value) {
      centerFocusIndex.value = closestIndex;
    }
  }

  void toggleFocusReadingMode() {
    isFocusReadingMode.value = !isFocusReadingMode.value;
    if (isFocusReadingMode.value) {
      _updateCenterFocusIndex();
    }
  }

  Future<void> loadContent({
    required String audioPath,
    required String transcriptPath,
    required bool audioIsLocalFile,
    required bool transcriptIsLocalFile,
  }) async {
    isLoading.value = true;
    try {
      // 1. Load Transcript
      if (transcriptPath.isNotEmpty) {
        final transcriptContent = transcriptIsLocalFile
            ? await File(transcriptPath).readAsString()
            : await rootBundle.loadString(transcriptPath);
        segments.value = TranscriptParser.parseJsonString(transcriptContent);
      }

      // 2. Load Audio
      bool hasAudio = false;
      if (audioPath.isNotEmpty) {
        try {
          if (audioIsLocalFile) {
            await _player.setFilePath(audioPath);
          } else {
            await _player.setAsset(audioPath);
          }
          hasAudio = true;
        } catch (e) {
          debugPrint('Error loading audio: $e');
        }
      }

      // 3. Determine Mode
      final hasTimings = segments.any((s) => s.start > 0 || s.end > 0);
      
      if (!hasAudio) {
        readingMode.value = ReadingMode.textOnly;
        isTextOnlyMode.value = true;
      } else if (!hasTimings) {
        readingMode.value = ReadingMode.audioOnlyText;
      } else {
        readingMode.value = ReadingMode.synced;
      }

    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentSegment(Duration position) {
    if (isTextOnlyMode.value) return;

    final index = transcriptSyncEngine.findSegmentIndexByTime(
      segments,
      position.inMilliseconds / 1000.0,
    );
    if (index != -1 && index != currentSegmentIndex.value) {
      currentSegmentIndex.value = index;
      _scrollToIndex(index);
    }
  }

  void _scrollToIndex(int index) {
    if (!itemScrollController.isAttached) return;

    // Check if the item is already comfortably visible
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final targetPos = positions.where((p) => p.index == index).toList();
      if (targetPos.isNotEmpty) {
        final pos = targetPos.first;
        
        // Thresholds for "comfortable" visibility
        const double topThreshold = 0.1;
        const double bottomThreshold = 0.9;

        // Special case for the first few items: if index is small and it's already at the top, don't scroll
        if (index < 5 && pos.itemLeadingEdge >= 0 && pos.itemLeadingEdge < topThreshold) {
          return;
        }

        // If item is already well within the viewport, don't scroll
        if (pos.itemLeadingEdge >= topThreshold && pos.itemTrailingEdge <= bottomThreshold) {
          return;
        }
      }
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      alignment: 0.25,
    );
  }

  void seekToWithDebounce(Duration position) {
    if (isTextOnlyMode.value) return;
    isUserSeeking.value = true;
    _player.seek(position);
    _seekDebounce?.cancel();
    _seekDebounce = Timer(const Duration(milliseconds: 250), () {
      _updateCurrentSegment(position);
      isUserSeeking.value = false;
    });
  }

  void onTapSegment(int index) {
    currentSegmentIndex.value = index;
    // For single tap, we only highlight visually as per requirements.
    // If audio is playing, it will eventually sync back to current position.
  }

  void onDoubleTapSegment(TranscriptSegment segment, int index) {
    currentSegmentIndex.value = index;
    seekToWithDebounce(Duration(milliseconds: (segment.start * 1000).round()));
  }

  void togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void skipForward() => seekToWithDebounce(currentPosition.value + const Duration(seconds: 10));

  void skipBackward() {
    final candidate = currentPosition.value - const Duration(seconds: 10);
    seekToWithDebounce(candidate.isNegative ? Duration.zero : candidate);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    _player.setSpeed(speed);
  }

  void toggleTextOnlyMode() {
    isTextOnlyMode.value = !isTextOnlyMode.value;
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    _seekDebounce?.cancel();
    _player.dispose();
    super.onClose();
  }
}
