import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _isConnected = true.obs;
  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    _isConnected.value = results.any((r) => r != ConnectivityResult.none);
    Connectivity().onConnectivityChanged.listen((results) {
      _isConnected.value = results.any((r) => r != ConnectivityResult.none);
    });
  }

  static Future<bool> checkNow() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  void showOfflineSnackbar({String? message}) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'No Internet',
      message ?? 'Please turn on your internet connection.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      margin: const EdgeInsets.all(12),
    );
  }
}
