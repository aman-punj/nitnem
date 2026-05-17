import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nitnem/models/support_request_model.dart';
import 'package:nitnem/services/support_service.dart';

enum SupportRequestType { feedback, bug }

class SupportFormController extends GetxController {
  SupportFormController({required this.type, required this.supportService});

  final SupportRequestType type;
  final SupportService supportService;

  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final emailController = TextEditingController();

  final isSubmitting = false.obs;

  String get requestTypeValue => type == SupportRequestType.feedback ? 'feedback' : 'bug';

  String get pageTitle => type == SupportRequestType.feedback ? 'Feedback' : 'Report Issue';

  Future<bool> submit() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();
    final email = emailController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      Get.snackbar('Required', 'Please fill title and message.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final request = SupportRequestModel(
        type: requestTypeValue,
        title: title,
        message: message,
        email: email,
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        platform: Platform.operatingSystem,
      );

      await supportService.submitRequest(request);
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Could not submit request. Please try again.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
