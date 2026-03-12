import 'dart:io';
import 'package:nitnem/services/prayer_storage_service.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TranscriptPathService {
  final PrayerStorageService storageService;

  TranscriptPathService({required this.storageService});

  Future<String> getTranscriptPath({
    required String prayerId,
    required String languageCode,
  }) async {
    // 1. First try to get downloaded file
    final localFile = await storageService.getLocalTranscriptFile(
      languageCode: languageCode,
      prayerId: prayerId,
    );

    // 2. Check if downloaded file exists and is valid
    if (await _isValidDownloadedFile(localFile)) {
      return localFile!.path;
    }

    // 3. Fallback to bundled asset
    return 'assets/texts/${_validateLanguageCode(languageCode)}/$prayerId.json';
  }

  Future<bool> _isValidDownloadedFile(File? file) async {
    if (file == null || !await file.exists()) return false;

    // Check if app was updated since download
    final packageInfo = await PackageInfo.fromPlatform();
    final appInfo = SharedPrefsService.getAppInfo();

    if (appInfo.currentVersion != packageInfo.version) {
      // Clear outdated downloads if app version changed
      await storageService.cleanDownloadedFiles();
      return false;
    }

    return true;
  }

  String _validateLanguageCode(String code) {
    const supportedLanguages = ['en', 'hi', 'pn'];
    return supportedLanguages.contains(code) ? code : 'en';
  }
}