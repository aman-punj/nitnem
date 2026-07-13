import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart' show MediaItem;

class AudioPlaybackService extends GetxService {
  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subs = [];
  Timer? _seekDebounce;

  final RxBool isPlaying = false.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    _player = Get.find<AudioPlayer>();

    _subs.add(_player.positionStream.listen((position) {
      currentPosition.value = position;
    }));
    _subs.add(_player.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    }));
    _subs.add(_player.playingStream.listen((playing) {
      isPlaying.value = playing;
    }));
    _subs.add(_player.speedStream.listen((speed) {
      playbackSpeed.value = speed;
    }));
  }

  Future<bool> loadAudio({
    required String audioPath,
    required bool isLocalFile,
    required String title,
    required Uri? artworkUri,
    String? contentId,
  }) async {
    try {
      final tag = MediaItem(
        id: 'prayer_${contentId ?? audioPath}',
        title: title,
        artist: 'Nitnem',
        artUri: artworkUri,
      );
      final audioSource = isLocalFile
          ? AudioSource.file(audioPath, tag: tag)
          : AudioSource.uri(Uri.parse('asset:///$audioPath'), tag: tag);
      await _player.setAudioSource(audioSource);
      return true;
    } catch (e) {
      debugPrint('Error loading audio in service: $e');
      return false;
    }
  }

  void togglePlayback() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void play() => _player.play();
  void pause() => _player.pause();

  void seek(Duration position) {
    _player.seek(position);
  }

  void seekToWithDebounce(Duration position) {
    _player.seek(position);
    _seekDebounce?.cancel();
    _seekDebounce = Timer(const Duration(milliseconds: 250), () {
      currentPosition.value = position;
    });
  }

  void skipForward() {
    seekToWithDebounce(currentPosition.value + const Duration(seconds: 10));
  }

  void skipBackward() {
    final candidate = currentPosition.value - const Duration(seconds: 10);
    seekToWithDebounce(candidate.isNegative ? Duration.zero : candidate);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    _player.setSpeed(speed);
  }

  @override
  void onClose() {
    _seekDebounce?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.onClose();
  }
}
