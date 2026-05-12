import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/content_item.dart';
import '../models/transcript_segment.dart';
import '../services/local_content_service.dart';
import '../services/transcript_parser.dart';
import '../services/transcript_sync_engine.dart';
import '../services/transcript_sync_service.dart';

enum ReadingMode { synced, audioOnlyText, textOnly }

class PrayerController extends GetxController {
  PrayerController({
    required this.transcriptSyncEngine,
    TranscriptSyncService? syncService,
    LocalContentService? localContentService,
  })  : _syncService = syncService,
        _localContentService = localContentService;

  final TranscriptSyncEngine transcriptSyncEngine;
  final TranscriptSyncService? _syncService;
  final LocalContentService? _localContentService;

  final AudioPlayer _player = AudioPlayer();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final RxList<TranscriptSegment> segments = <TranscriptSegment>[].obs;
  final RxInt currentSegmentIndex = (-1).obs;
  final RxInt centerFocusIndex = (-1).obs;
  final RxInt selectedIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = ''.obs;
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
    ContentItem? item,
    String? currentLang,
  }) async {
    isLoading.value = true;
    loadingMessage.value = 'Preparing prayer...';
    
    try {
      String finalAudioPath = audioPath;
      String finalTranscriptPath = transcriptPath;
      bool finalAudioIsLocal = audioIsLocalFile;
      bool finalTranscriptIsLocal = transcriptIsLocalFile;

      // 1. Check if we need to sync first (e.g. content was just added from backend)
      if (item != null && _syncService != null && _localContentService != null) {
        if (finalAudioPath.isEmpty || finalTranscriptPath.isEmpty) {
          loadingMessage.value = 'Downloading prayer content...';
          await _syncService.syncContent(item);
          
          final localMetadata = _localContentService.getSyncMetadata(item.id);
          if (localMetadata != null) {
            finalAudioPath = localMetadata.audioLocalPath ?? '';
            finalTranscriptPath = localMetadata.transcriptLocalPaths[currentLang ?? 'pa'] ?? '';
            finalAudioIsLocal = finalAudioPath.isNotEmpty;
            finalTranscriptIsLocal = finalTranscriptPath.isNotEmpty;
          }
        }
      }

      loadingMessage.value = 'Loading transcript...';
      // 2. Load Transcript
      if (finalTranscriptPath.isNotEmpty) {
        final transcriptContent = finalTranscriptIsLocal
            ? await File(finalTranscriptPath).readAsString()
            : await rootBundle.loadString(finalTranscriptPath);
        segments.value = TranscriptParser.parseJsonString(transcriptContent);
      }

      loadingMessage.value = 'Loading audio...';
      // 3. Load Audio
      bool hasAudio = false;
      if (finalAudioPath.isNotEmpty) {
        try {
          if (finalAudioIsLocal) {
            await _player.setFilePath(finalAudioPath);
          } else {
            await _player.setAsset(finalAudioPath);
          }
          hasAudio = true;
        } catch (e) {
          debugPrint('Error loading audio: $e');
        }
      }

      // 4. Determine Mode
      final hasTimings = segments.any((s) => s.start > 0 || s.end > 0);
      
      if (!hasAudio) {
        readingMode.value = ReadingMode.textOnly;
        isTextOnlyMode.value = true;
      } else if (!hasTimings) {
        readingMode.value = ReadingMode.audioOnlyText;
      } else {
        readingMode.value = ReadingMode.synced;
      }

    } catch (e) {
      debugPrint('Error in loadContent: $e');
      Get.snackbar('Error', 'Failed to load prayer content');
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
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
