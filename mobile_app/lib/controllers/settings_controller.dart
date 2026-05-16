import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/services/cache_service.dart';

class SettingsController extends GetxController {
  final RxBool isKeepAwakeEnabled = false.obs;
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
}
