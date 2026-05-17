import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class CacheService {
  Future<String> getStorageUsage() async {
    final prayersDirectory = await _prayersDirectory();
    int totalSize = 0;

    if (!await prayersDirectory.exists()) return '0.0 MB';

    final List<FileSystemEntity> entities =
        await prayersDirectory.list(recursive: true).toList();
    for (final entity in entities) {
      if (entity is File) {
        final path = entity.path;
        if (path.endsWith('.mp3') ||
            path.endsWith('.wav') ||
            path.endsWith('.json')) {
          totalSize += await entity.length();
        }
      }
    }

    final mb = totalSize / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> clearPrayerPlaybackCache() async {
    try {
      final prayersDirectory = await _prayersDirectory();

      // 1. Remove only prayer playback assets (audio + transcripts).
      if (await prayersDirectory.exists()) {
        await prayersDirectory.delete(recursive: true);
      }

      // 2. Remove only prayer sync metadata keys.
      final prefs = SharedPrefsService.instance;
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('sync_metadata_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  Future<Directory> _prayersDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}/prayers');
  }
}
