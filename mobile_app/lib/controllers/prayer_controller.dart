import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart' show MediaItem;
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/mini_player_controller.dart';
import '../models/content_item.dart';
import '../bindings/di.dart';
import '../models/transcript_segment.dart';
import '../services/local_content_service.dart';
import '../services/transcript_parser.dart';
import '../services/transcript_sync_engine.dart';
import '../services/transcript_sync_service.dart';

enum PrimaryMode { audio, focus }

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

  // Shared singleton player from DI — NOT disposed by this controller.
  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subs = [];
  Uri? _artworkFileUri;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final RxString prayerTitle = ''.obs;
  final RxList<TranscriptSegment> segments = <TranscriptSegment>[].obs;
  final RxInt currentSegmentIndex = (-1).obs;
  final RxInt centerFocusIndex = (-1).obs;
  final RxInt selectedIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = ''.obs;

  final Rx<PrimaryMode> primaryMode = PrimaryMode.audio.obs;
  final RxBool hasTimings = false.obs;
  final RxBool hasAudio = false.obs;

  final RxBool isUserSeeking = false.obs;
  final RxBool enableHindi = false.obs;
  final RxBool enableEnglish = false.obs;
  final RxString languageCode = 'pn'.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  final RxBool isHeaderVisible = true.obs;
  final RxBool hasShownSyncWarning = false.obs;
  Timer? _headerHideTimer;
  Timer? _seekDebounce;

  bool _contentLoaded = false;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();

    // Resolve the shared player. DI.initAudioBackground() always puts one;
    // the fallback creates a fresh player if somehow called before that.
    _player = Get.isRegistered<AudioPlayer>()
        ? Get.find<AudioPlayer>()
        : AudioPlayer();

    _subs.add(_player.positionStream.listen((position) {
      currentPosition.value = position;
      if (!isUserSeeking.value && primaryMode.value == PrimaryMode.audio && hasTimings.value) {
        _updateCurrentSegment(position);
      }
    }));
    _subs.add(_player.durationStream.listen((duration) {
      if (duration != null) totalDuration.value = duration;
    }));
    _subs.add(_player.playingStream.listen((playing) {
      isPlaying.value = playing;
      if (playing) {
        _startHeaderHideTimer();
      } else {
        showHeader();
      }
    }));

    itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  Future<Uri?> _resolveArtworkUri() async {
    if (_artworkFileUri != null) return _artworkFileUri;
    try {
      final bytes = await rootBundle.load('assets/images/bani_sagar_logo_black_bg.png');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bani_sagar_logo_notification.png');
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
      _artworkFileUri = Uri.file(file.path);
      return _artworkFileUri;
    } catch (e) {
      debugPrint('Failed to prepare artwork file: $e');
      return null;
    }
  }

  void _onScroll() {
    if (primaryMode.value == PrimaryMode.focus) {
      _updateCenterFocusIndex();
    }
    showHeader();
  }

  void showHeader() {
    isHeaderVisible.value = true;
    if (isPlaying.value) {
      _startHeaderHideTimer();
    }
  }

  void _startHeaderHideTimer() {
    _headerHideTimer?.cancel();
    _headerHideTimer = Timer(const Duration(seconds: 5), () {
      if (isPlaying.value) {
        isHeaderVisible.value = false;
      }
    });
  }

  void _updateCenterFocusIndex() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Target the 0.4 mark (slightly above middle) for the "magnifying glass"
    const double targetAlignment = 0.4;
    double minDistance = 1.0;
    int closestIndex = -1;

    for (final position in positions) {
      // Skip flower icons (index 0 for top, segments.length + 1 for bottom)
      if (position.index == 0 || position.index == segments.length + 1) continue;

      final center = (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
      final distance = (center - targetAlignment).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = position.index - 1;
      }
    }

    if (closestIndex != -1 && closestIndex != centerFocusIndex.value) {
      centerFocusIndex.value = closestIndex;
    }
  }

  void setPrimaryMode(PrimaryMode mode) {
    final oldMode = primaryMode.value;
    primaryMode.value = mode;

    if (mode == PrimaryMode.audio) {
      if (!hasTimings.value && !hasShownSyncWarning.value) {
        hasShownSyncWarning.value = true;
        Get.snackbar(
          'Sync Unavailable',
          'Lyric synchronization is not available for this prayer.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withValues(alpha: 0.7),
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        );
      }

      // Sync audio to what was centered in Focus mode
      if (oldMode == PrimaryMode.focus && centerFocusIndex.value != -1 && hasAudio.value && hasTimings.value) {
        final segment = segments[centerFocusIndex.value];
        if (segment.start >= 0) {
          seekToWithDebounce(Duration(milliseconds: (segment.start * 1000).round()));
        }
      }
      _updateCurrentSegment(currentPosition.value);
    } else {
      // Pause audio when entering Focus mode
      if (_player.playing) {
        _player.pause();
      }
      // Sync focus to what was playing in Audio mode
      if (currentSegmentIndex.value != -1) {
        centerFocusIndex.value = currentSegmentIndex.value;
        _scrollToCenter(currentSegmentIndex.value);
      } else if (segments.isNotEmpty) {
        // If nothing playing, center the first line
        centerFocusIndex.value = 0;
        _scrollToCenter(0);
      }
    }
    showHeader();
  }

  void _scrollToCenter(int index) {
    if (!itemScrollController.isAttached || segments.isEmpty) return;
    itemScrollController.scrollTo(
      index: hasTimings.value ? index + 1 : index, // Offset for flower icon only if sync available
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.4, // Slightly above center for better reading position
    );
  }

  Future<void> loadContent({
    required String audioPath,
    required String transcriptPath,
    required bool audioIsLocalFile,
    required bool transcriptIsLocalFile,
    ContentItem? item,
    String? currentLang,
  }) async {
    if (_contentLoaded) return;

    // skipAudio=true means the audio is already running in the player (same
    // prayer re-opened from mini bar). We still need to load the transcript.
    bool skipAudio = false;

    if (Get.isRegistered<MiniPlayerController>()) {
      final mini = Get.find<MiniPlayerController>();
      if (mini.isActive.value) {
        if (mini.navArgs?.audioPath == audioPath) {
          if (segments.isNotEmpty) {
            // Controller is fully intact — nothing to do.
            _contentLoaded = true;
            isLoading.value = false;
            hasAudio.value = true;
            return;
          }
          // Controller was recreated by GetX — transcript is gone but audio
          // is still playing. Load transcript only, skip setAudioSource.
          skipAudio = true;
        } else {
          // Different prayer — stop old audio immediately.
          mini.dismiss();
        }
      }
    }

    isLoading.value = true;
    loadingMessage.value = 'Preparing prayer...';

    try {
      // Ensure JustAudioBackground initialization completed before player setup.
      await DependencyInjection.audioBackgroundReady;

      String finalAudioPath = audioPath;
      String finalTranscriptPath = transcriptPath;
      bool finalAudioIsLocal = audioIsLocalFile;
      bool finalTranscriptIsLocal = transcriptIsLocalFile;

      // Verify file existence
      if (finalAudioIsLocal && !(await File(finalAudioPath).exists())) {
        finalAudioPath = '';
        finalAudioIsLocal = false;
      }
      if (finalTranscriptIsLocal && !(await File(finalTranscriptPath).exists())) {
        finalTranscriptPath = '';
        finalTranscriptIsLocal = false;
      }

      // 1. Check if we need to sync first
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
      // Skip setAudioSource when resuming the same prayer — audio is already
      // running in the singleton player, reloading it would restart from zero.
      bool audioLoaded = skipAudio;
      if (!skipAudio && finalAudioPath.isNotEmpty) {
        try {
          final artUri = await _resolveArtworkUri();
          final tag = MediaItem(
            id: 'prayer_${item?.id ?? audioPath}',
            title: prayerTitle.value,
            artist: 'Nitnem',
            artUri: artUri,
          );
          final audioSource = finalAudioIsLocal
              ? AudioSource.file(finalAudioPath, tag: tag)
              : AudioSource.uri(Uri.parse('asset:///$finalAudioPath'), tag: tag);
          await _player.setAudioSource(audioSource);
          audioLoaded = true;
        } catch (e) {
          debugPrint('Error loading audio: $e');
        }
      }
      hasAudio.value = audioLoaded;

      // 4. Determine Capabilities
      hasTimings.value = segments.any((s) => s.start > 0 || s.end > 0);

      // 5. Default Mode
      if (hasAudio.value) {
        primaryMode.value = PrimaryMode.audio;
      } else {
        primaryMode.value = PrimaryMode.focus;
      }

      _contentLoaded = true;

      // Notify the global mini-player so it can show the persistent bar.
      if (Get.isRegistered<MiniPlayerController>()) {
        Get.find<MiniPlayerController>().setCurrentPrayer(
          title: prayerTitle.value,
          hasAudio: hasAudio.value,
          thumbnailUrl: item?.iconUrl ?? item?.thumbnail,
          navArgs: PrayerNavArgs(
            title: prayerTitle.value,
            audioPath: audioPath,
            transcriptPath: transcriptPath,
            audioIsLocalFile: finalAudioIsLocal,
            transcriptIsLocalFile: finalTranscriptIsLocal,
            contentItem: item,
            currentLang: currentLang,
          ),
        );
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
    if (!hasTimings.value) return;

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
      final targetPos = positions.where((p) => p.index == (hasTimings.value ? index + 1 : index)).toList();
      if (targetPos.isNotEmpty) {
        final pos = targetPos.first;

        const double topThreshold = 0.15;
        const double bottomThreshold = 0.7;

        if (pos.itemLeadingEdge >= topThreshold && pos.itemTrailingEdge <= bottomThreshold) {
          return;
        }
      }
    }

    itemScrollController.scrollTo(
      index: hasTimings.value ? index + 1 : index, // Offset for flower icon only if sync available
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
      alignment: 0.35,
    );
  }

  void seekToWithDebounce(Duration position) {
    if (primaryMode.value == PrimaryMode.focus && !hasAudio.value) return;
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
  }

  void onDoubleTapSegment(TranscriptSegment segment, int index) {
    currentSegmentIndex.value = index;
    if (hasAudio.value) {
      seekToWithDebounce(Duration(milliseconds: (segment.start * 1000).round()));
    }
  }

  void togglePlayback() {
    if (!hasAudio.value) return;
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void skipForward() {
    if (!hasAudio.value) return;
    seekToWithDebounce(currentPosition.value + const Duration(seconds: 10));
  }

  void skipBackward() {
    if (!hasAudio.value) return;
    final candidate = currentPosition.value - const Duration(seconds: 10);
    seekToWithDebounce(candidate.isNegative ? Duration.zero : candidate);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    _player.setSpeed(speed);
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    // Cancel stream subscriptions from this controller instance.
    // Do NOT dispose _player — it is a permanent singleton shared across pages.
    for (final sub in _subs) {
      sub.cancel();
    }
    itemPositionsListener.itemPositions.removeListener(_onScroll);
    _seekDebounce?.cancel();
    _headerHideTimer?.cancel();
    super.onClose();
  }
}
