import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nitnem/services/prayer_storage_service.dart';

class PrayerUpdateService {
  static const String baseRawUrl =
      'https://raw.githubusercontent.com/aman-punj/nitnem_prayers/refs/heads/main/nitnem_prayers';

  final PrayerStorageService _storageService = PrayerStorageService();

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
}
