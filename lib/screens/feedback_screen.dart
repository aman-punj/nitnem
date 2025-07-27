import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feedback_controller.dart';

class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({super.key});

  final FeedbackController controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.feedbackTextController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final image = controller.selectedImage.value;
              return image != null
                  ? Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(image, height: 150),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: controller.removeImage,
                  ),
                ],
              )
                  : const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: controller.submitFeedback,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
