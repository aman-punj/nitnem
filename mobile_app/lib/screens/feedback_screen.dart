import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/support_form_controller.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_bar.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:nitnem/core/design_system/widgets/support_request_form.dart';
import 'package:nitnem/screens/report_issue_screen.dart';
import 'package:nitnem/services/support_service.dart';

class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({super.key});

  final SupportFormController controller = Get.put(
    SupportFormController(
      type: SupportRequestType.feedback,
      supportService: Get.find<SupportService>(),
    ),
    tag: 'feedback_form',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SacredDsAppBar(title: 'Feedback'),
      body: SupportRequestForm(
        controller: controller,
        trailingAction: SacredButton(
          label: 'Report an issue instead',
          fullWidth: true,
          variant: SacredButtonVariant.secondary,
          onPressed: () => Get.to(() => ReportIssueScreen()),
        ),
      ),
    );
  }
}
