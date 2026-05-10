import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nitnem/models/prayer_track_metadata.dart';
import 'package:nitnem/services/prayer_asset_service.dart';
import 'package:nitnem/services/prayer_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerUpdateService {
  static const String baseRawUrl =
      'https://raw.githubusercontent.com/aman-punj/nitnem_prayers/refs/heads/main/nitnem_prayers';

  final PrayerStorageService _storageService = PrayerStorageService();
  final PrayerAssetService _assetService = PrayerAssetService();

  Future<void> fetchUpdatedPrayers(List<String> updateFor) async {
    try {

      for (final path in updateFor) {
        final parts = path.split('/');
        if (parts.length != 2) continue;

        final languageCode = parts[0];
        final prayerId = parts[1];

        final url = '$baseRawUrl/$languageCode/$prayerId.json';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          // Save to local storage
          await _storageService.saveTranscript(
            prayerId: prayerId,
            languageCode: languageCode,
            content: jsonDecode(response.body),
            // version: packageInfo.version,
          );
        }
      }
    } catch (e) {
      print('Error in fetchUpdatedPrayers: $e');
      rethrow;
    }
  }

  Future<void> syncTrackAssets({
    required String prayerId,
    required PrayerTrackMetadata track,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final audioKey = 'asset_audio_${prayerId}_${track.id}';
    final paKey = 'asset_pa_${prayerId}_${track.id}';

    if (track.audioUrl != null && prefs.getString(audioKey) != track.audioVersion) {
      final audioResponse = await http.get(Uri.parse(track.audioUrl!));
      if (audioResponse.statusCode == 200) {
        await _assetService.saveAudioBytes(
          prayerId: prayerId,
          trackId: track.id,
          bytes: audioResponse.bodyBytes,
        );
        await prefs.setString(audioKey, track.audioVersion);
      }
    }

    if (track.paUrl != null && prefs.getString(paKey) != track.lyricsVersion) {
      final paResponse = await http.get(Uri.parse(track.paUrl!));
      if (paResponse.statusCode == 200) {
        await _assetService.saveTranscript(
          prayerId: prayerId,
          languageCode: 'pn',
          trackId: track.id,
          content: paResponse.body,
        );
        await prefs.setString(paKey, track.lyricsVersion);
      }
    }
  }
}
