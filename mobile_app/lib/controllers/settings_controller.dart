import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/services/cache_service.dart';

class SettingsController extends GetxController {
  final RxBool isKeepAwakeEnabled = false.obs;
  final RxBool isClearingCache = false.obs;
  final RxString storageUsage = 'Calculating...'.obs;
  final CacheService _cacheService = Get.find<CacheService>();

  @override
  void onInit() {
    super.onInit();
    isKeepAwakeEnabled.value = SharedPrefsService.getBool('keep_awake', defaultValue: false);
    refreshStorageUsage();
  }

  @override
  void onReady() {
    super.onReady();
    _applyKeepAwake(isKeepAwakeEnabled.value);
  }

  Future<void> refreshStorageUsage() async {
    storageUsage.value = await _cacheService.getStorageUsage();
  }

  void toggleKeepAwake(bool enabled) {
    isKeepAwakeEnabled.value = enabled;
    SharedPrefsService.setBool('keep_awake', enabled);
    _applyKeepAwake(enabled);
  }

  void _applyKeepAwake(bool enabled) {
    if (enabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  Future<void> clearPrayerCache() async {
    if (isClearingCache.value) return;
    isClearingCache.value = true;
    try {
      if (Get.isRegistered<AudioPlayer>()) {
        final player = Get.find<AudioPlayer>();
        await player.stop();
      }
      await _cacheService.clearPrayerPlaybackCache();
      await refreshStorageUsage();
      Get.snackbar('Cache Cleared', 'Prayer audio and transcript cache cleared successfully.');
    } catch (_) {
      Get.snackbar('Error', 'Could not clear prayer cache. Please try again.');
    } finally {
      isClearingCache.value = false;
    }
  }
}
