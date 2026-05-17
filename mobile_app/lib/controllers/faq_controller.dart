import 'package:get/get.dart';
import 'package:nitnem/models/faq_item.dart';
import 'package:nitnem/services/support_service.dart';

class FaqController extends GetxController {
  FaqController({required SupportService supportService}) : _supportService = supportService;

  final SupportService _supportService;

  final items = <FaqItem>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      items.value = await _supportService.fetchEnabledFaqs();
    } catch (_) {
      items.clear();
      errorMessage.value = 'Unable to load FAQ right now.';
    } finally {
      isLoading.value = false;
    }
  }
}
