import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/design_system/tokens/colors.dart';
import '../core/design_system/widgets/sacred_app_bar.dart';

import '../controllers/feedback_controller.dart';

class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({super.key});

  final FeedbackController controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: const SacredDsAppBar(title: "Feedback"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Feedback Input
            Container(
              decoration: BoxDecoration(
                color: SacredColors.surfacePrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SacredColors.borderGold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.feedbackTextController,
                maxLines: 5,
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: const TextStyle(
                  color: SacredColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your feedback...',
                  hintStyle: TextStyle(color: SacredColors.textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Image Preview
            Obx(() {
              final image = controller.selectedImage.value;
              return image != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: SacredColors.borderGold.withValues(alpha: 0.3),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close,
                                  size: 18, color: Colors.white),
                              onPressed: controller.removeImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink();
            }),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(
                      Icons.image,
                      size: 18,
                      color: SacredColors.primaryAccent,
                    ),
                    label: const Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SacredColors.surfacePrimary,
                      foregroundColor: SacredColors.textPrimary,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: SacredColors.borderGold.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.submitFeedback,
                    icon: const Icon(Icons.send, size: 18, color: Colors.black),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SacredColors.primaryAccent,
                      foregroundColor: Colors.black,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
