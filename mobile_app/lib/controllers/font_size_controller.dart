import 'package:get/get.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class FontSizeController extends GetxController {
  // Discrete steps: 0 (Small=0.9), 1 (Medium=1.0), 2 (Large=1.2)
  final RxInt _currentStep = 1.obs;
  final List<double> _scales = [0.9, 1.0, 1.2];

  double get fontSizeScale => _scales[_currentStep.value];
  int get currentStep => _currentStep.value;

  @override
  void onInit() {
    super.onInit();
    // Load saved index (0, 1, or 2), default to 1 (Medium)
    _currentStep.value = SharedPrefsService.instance.getInt('font_size_step') ?? 1;
  }

  void setFontSizeStep(int step) {
    if (step < 0 || step >= _scales.length) return;
    _currentStep.value = step;
    SharedPrefsService.instance.setInt('font_size_step', step);
  }
}
