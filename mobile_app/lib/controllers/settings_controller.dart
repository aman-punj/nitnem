import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class SettingsController extends GetxController {
  final RxBool isKeepAwakeEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isKeepAwakeEnabled.value = SharedPrefsService.getBool('keep_awake', defaultValue: false);
    _applyKeepAwake(isKeepAwakeEnabled.value);
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
