import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../models/content_item.dart';
import '../services/shared_prefs_service.dart';

class PrayerNavArgs {
  final String title;
  final String? gurmukhiTitle;
  final String audioPath;
  final String transcriptPath;
  final bool audioIsLocalFile;
  final bool transcriptIsLocalFile;
  final ContentItem? contentItem;
  final String? currentLang;

  const PrayerNavArgs({
    required this.title,
    this.gurmukhiTitle,
    required this.audioPath,
    required this.transcriptPath,
    this.audioIsLocalFile = false,
    this.transcriptIsLocalFile = false,
    this.contentItem,
    this.currentLang,
  });
}

class MiniPlayerController extends GetxController with WidgetsBindingObserver {
  static const _kBgPlay = 'mini_player_bg_play';

  final RxBool isActive = false.obs;
  final RxString prayerTitle = ''.obs;
  final RxString thumbnailUrl = ''.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool allowBackgroundPlay = true.obs;

  PrayerNavArgs? _navArgs;
  PrayerNavArgs? get navArgs => _navArgs;

  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _player = Get.find<AudioPlayer>();

    _subs.add(_player.playingStream.listen((v) => isPlaying.value = v));
    _subs.add(_player.positionStream.listen((v) => position.value = v));
    _subs.add(_player.durationStream.listen((v) {
      if (v != null) totalDuration.value = v;
    }));

    allowBackgroundPlay.value =
        SharedPrefsService.instance.getBool(_kBgPlay) ?? true;
  }

  void setCurrentPrayer({
    required String title,
    required bool hasAudio,
    required PrayerNavArgs navArgs,
    String? thumbnailUrl,
  }) {
    prayerTitle.value = title;
    this.thumbnailUrl.value = thumbnailUrl ?? '';
    _navArgs = navArgs;
    isActive.value = hasAudio;
  }

  void dismiss() {
    _player.pause();
    isActive.value = false;
    prayerTitle.value = '';
    thumbnailUrl.value = '';
    _navArgs = null;
  }

  void toggleBackgroundPlay() {
    allowBackgroundPlay.value = !allowBackgroundPlay.value;
    SharedPrefsService.instance.setBool(_kBgPlay, allowBackgroundPlay.value);
  }

  void togglePlayback() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!allowBackgroundPlay.value && _player.playing) {
        _player.pause();
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final sub in _subs) {
      sub.cancel();
    }
    super.onClose();
  }
}
