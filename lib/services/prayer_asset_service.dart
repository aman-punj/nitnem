import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PrayerAssetService {
  Future<Directory> _root() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory('${dir.path}/prayers');
  }

  Future<String> transcriptPath({
    required String prayerId,
    required String languageCode,
    required String trackId,
  }) async {
    final root = await _root();
    return '${root.path}/$prayerId/$trackId/transcript_$languageCode.json';
  }

  Future<String> audioPath({required String prayerId, required String trackId}) async {
    final root = await _root();
    return '${root.path}/$prayerId/$trackId/audio.mp3';
  }

  Future<File?> existingTranscript({
    required String prayerId,
    required String languageCode,
    String trackId = 'default',
  }) async {
    final file = File(await transcriptPath(
      prayerId: prayerId,
      languageCode: languageCode,
      trackId: trackId,
    ));
    return file.existsSync() ? file : null;
  }

  Future<File?> existingAudio({required String prayerId, String trackId = 'default'}) async {
    final file = File(await audioPath(prayerId: prayerId, trackId: trackId));
    return file.existsSync() ? file : null;
  }

  Future<void> saveTranscript({
    required String prayerId,
    required String languageCode,
    required String trackId,
    required String content,
  }) async {
    final file = File(await transcriptPath(
      prayerId: prayerId,
      languageCode: languageCode,
      trackId: trackId,
    ));
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> saveAudioBytes({
    required String prayerId,
    required String trackId,
    required List<int> bytes,
  }) async {
    final file = File(await audioPath(prayerId: prayerId, trackId: trackId));
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}
