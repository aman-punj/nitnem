import 'dart:convert';
import 'dart:io';

import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:path_provider/path_provider.dart';

class PrayerStorageService {
  Future<String> _getLocalPath(String languageCode, String prayerId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$languageCode/$prayerId.json';
  }

  Future<void> saveTranscript({
    required String languageCode,
    required String prayerId,
    required Map<String, dynamic> content,
  }) async {
    final path = await _getLocalPath(languageCode, prayerId);
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(content));
  }

  Future<File?> getLocalTranscriptFile({
    required String languageCode,
    required String prayerId,
  }) async {
    final path = await _getLocalPath(languageCode, prayerId);
    final file = File(path);
    return await file.exists() ? file : null;
  }

  Future<void> cleanDownloadedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final prayersDir = Directory('${dir.path}/prayers');

      if (await prayersDir.exists()) {
        await prayersDir.delete(recursive: true);
      }
      await SharedPrefsService.clearWithKey("app_info");
    } catch (_) {}
  }
}
