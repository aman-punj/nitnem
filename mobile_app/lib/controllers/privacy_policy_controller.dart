import 'package:get/get.dart';
import 'package:nitnem/models/privacy_policy_content.dart';
import 'package:nitnem/services/support_service.dart';

class PrivacyPolicyController extends GetxController {
  PrivacyPolicyController({required SupportService supportService})
      : _supportService = supportService;

  final SupportService _supportService;

  final content = const PrivacyPolicyContent(title: 'Privacy Policy', content: '').obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      content.value = await _supportService.fetchPrivacyPolicy();
    } finally {
      isLoading.value = false;
    }
  }
}
