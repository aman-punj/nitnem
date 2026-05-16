import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class CacheService {
  Future<String> getStorageUsage() async {
    final directory = await getApplicationDocumentsDirectory();
    int totalSize = 0;
    
    // Scan for audio files and transcript files
    final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();
    for (final entity in entities) {
      if (entity is File) {
        final path = entity.path;
        if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.json')) {
           totalSize += await entity.length();
        }
      }
    }
    
    final mb = totalSize / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> clearAllCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // 1. Remove audio/transcript files
      final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();
      for (final entity in entities) {
        if (entity is File) {
          final String path = entity.path;
          if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.json')) {
            await entity.delete();
          }
        }
      }
      
      // 2. Clear all sync metadata keys
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
}
