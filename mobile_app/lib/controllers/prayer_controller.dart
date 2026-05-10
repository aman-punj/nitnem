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

class PrayerController extends GetxController {
  PrayerController({required this.transcriptSyncEngine});

  final TranscriptSyncEngine transcriptSyncEngine;
  final AudioPlayer _player = AudioPlayer();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final RxList<TranscriptSegment> segments = <TranscriptSegment>[].obs;
  final RxInt currentSegmentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTextOnlyMode = false.obs;
  final RxBool isUserSeeking = false.obs;
  final RxBool enableHindi = false.obs;
  final RxBool enableEnglish = false.obs;
  final RxString languageCode = 'pn'.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  Timer? _seekDebounce;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    _player.positionStream.listen((position) {
      currentPosition.value = position;
      if (!isUserSeeking.value) {
        _updateCurrentSegment(position);
      }
    });
    _player.durationStream.listen((duration) {
      if (duration != null) totalDuration.value = duration;
    });
    _player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });
  }

  Future<void> loadContent({
    required String audioPath,
    required String transcriptPath,
    required bool audioIsLocalFile,
    required bool transcriptIsLocalFile,
  }) async {
    isLoading.value = true;
    try {
      final transcriptContent = transcriptIsLocalFile
          ? await File(transcriptPath).readAsString()
          : await rootBundle.loadString(transcriptPath);
      segments.value = TranscriptParser.parseJsonString(transcriptContent);

      if (audioIsLocalFile) {
        await _player.setFilePath(audioPath);
      } else {
        await _player.setAsset(audioPath);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentSegment(Duration position) {
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
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.25,
    );
  }

  void seekToWithDebounce(Duration position) {
    isUserSeeking.value = true;
    _player.seek(position);
    _seekDebounce?.cancel();
    _seekDebounce = Timer(const Duration(milliseconds: 250), () {
      _updateCurrentSegment(position);
      isUserSeeking.value = false;
    });
  }

  void onTapSegment(TranscriptSegment segment) {
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
