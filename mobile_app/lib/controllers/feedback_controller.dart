import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FeedbackController extends GetxController {
  final TextEditingController feedbackTextController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final isSubmitting = false.obs;
  final uploadProgress = 0.0.obs;

  static const _cloudName = 'dkkczx7db';
  static const _uploadPreset = 'nitnem_images';
  static const _folder = 'issues';
  static const _maxBytes = 1024 * 1024; // 1 MB

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked == null) return;

    final compressed = await _compressToUnder1MB(File(picked.path));
    selectedImage.value = compressed;
  }

  void removeImage() {
    selectedImage.value = null;
  }

  /// Compresses the image iteratively until it is under 1 MB.
  Future<File?> _compressToUnder1MB(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/feedback_img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    int quality = 80;
    XFile? result;

    do {
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
        minWidth: 1280,
        minHeight: 720,
        keepExif: false,
      );
      quality -= 15;
    } while (
        result != null &&
        await File(result.path).length() > _maxBytes &&
        quality > 10);

    return result != null ? File(result.path) : null;
  }

  /// Uploads [image] to Cloudinary and returns the secure URL.
  Future<String> _uploadToCloudinary(File image) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = _folder
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${streamed.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  Future<bool> submitFeedback() async {
    final text = feedbackTextController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Required', 'Please write your feedback before submitting.');
      return false;
    }

    isSubmitting.value = true;
    uploadProgress.value = 0;

    try {
      String? imageUrl;
      if (selectedImage.value != null) {
        uploadProgress.value = 0.3;
        imageUrl = await _uploadToCloudinary(selectedImage.value!);
        uploadProgress.value = 0.9;
      }

      await FirebaseFirestore.instance.collection('support_requests').add({
        'type': 'feedback',
        'message': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'platform': Platform.operatingSystem,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      uploadProgress.value = 1.0;
      return true;
    } catch (e) {
      debugPrint('FeedbackController.submitFeedback error: $e');
      Get.snackbar('Error', 'Could not submit feedback. Please try again.');
      return false;
    } finally {
      isSubmitting.value = false;
      uploadProgress.value = 0;
    }
  }

  @override
  void onClose() {
    feedbackTextController.dispose();
    super.onClose();
  }
}
