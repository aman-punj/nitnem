import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackController extends GetxController {
  final TextEditingController feedbackTextController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);

  void pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  void submitFeedback() {
    final feedbackText = feedbackTextController.text.trim();
    final imageFile = selectedImage.value;

    // You can print/debug to confirm values
    print('Feedback: $feedbackText');
    print('Image attached: ${imageFile != null}');

    // TODO: Send feedback to server later
  }

  @override
  void onClose() {
    feedbackTextController.dispose();
    super.onClose();
  }
}
