import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../models/hukamnama_model.dart';
import '../services/hukamnama_service.dart';
import '../services/shared_prefs_service.dart';

class HukamnamaController extends GetxController {
  final HukamnamaService _service;

  static const _kShownDate = 'hukamnama_shown_date';
  static const _widgetAndroidClass = 'com.banisagar.app.HukamnamaWidget';

  HukamnamaController({HukamnamaService? service})
      : _service = service ?? HukamnamaService();

  final Rx<HukamnamaModel?> hukamnama = Rx<HukamnamaModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _fetchAndSync();
  }

  Future<void> _fetchAndSync() async {
    final data = await _service.fetchToday();
    if (data == null) return;
    hukamnama.value = data;
    await _pushToWidget(data);
  }

  /// Returns true if the daily sheet hasn't been shown yet today.
  bool shouldShowTodaySheet() {
    final stored = SharedPrefsService.instance.getString(_kShownDate) ?? '';
    return stored != _todayKey();
  }

  void markSheetShown() {
    SharedPrefsService.instance.setString(_kShownDate, _todayKey());
  }

  Future<void> _pushToWidget(HukamnamaModel data) async {
    try {
      await HomeWidget.saveWidgetData<String>(
          'hukamnama_gurmukhi', data.gurmukhi);
      await HomeWidget.saveWidgetData<String>(
          'hukamnama_date', _formatDisplayDate(data.date));
      await HomeWidget.updateWidget(
          qualifiedAndroidName: _widgetAndroidClass);
    } catch (e) {
      // Widget update failing must not affect the in-app experience
      debugPrint('HukamnamaController: widget update failed: $e');
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
