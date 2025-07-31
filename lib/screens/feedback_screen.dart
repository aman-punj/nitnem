import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/utils/app_theme.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';

import '../controllers/feedback_controller.dart';

class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({super.key});

  final FeedbackController controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: SacredAppBar(title: "Feedback"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Feedback Input
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFDF7).withOpacity(0.95),
                    const Color(0xFFF5E6B8).withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4C19C).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                  color: Color(0xFF8B4513),
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your feedback...',
                  hintStyle: TextStyle(color: Color(0xFF8B4513)),
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
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close,
                                  size: 16, color: Colors.red),
                              onPressed: controller.removeImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink();
            }),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickImage,
                    icon: Icon(
                      Icons.image,
                      size: 18,
                      color: const Color(0xFF8B4513),
                    ),
                    label: const Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E5AB),
                      foregroundColor: const Color(0xFF8B4513),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.submitFeedback,
                    icon:
                        Icon(Icons.send, size: 18, color: AppTheme.lightCream),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: AppTheme.lightCream,
                      elevation: 4,
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
