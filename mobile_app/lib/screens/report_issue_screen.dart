import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/support_form_controller.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/support_request_form.dart';
import 'package:nitnem/services/support_service.dart';

class ReportIssueScreen extends StatelessWidget {
  ReportIssueScreen({super.key});

  final SupportFormController controller = Get.put(
    SupportFormController(
      type: SupportRequestType.bug,
      supportService: Get.find<SupportService>(),
    ),
    tag: 'bug_form',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SacredDsAppBar(title: 'Report Issue'),
      body: SupportRequestForm(controller: controller),
    );
  }
}
