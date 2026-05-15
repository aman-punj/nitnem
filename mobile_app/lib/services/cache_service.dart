import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  Future<void> clearDownloadedContent() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      
      // We assume downloaded files are in a specific subdirectory or have a specific pattern.
      // Based on architecture, it might be in 'assets/audios/' or downloaded paths.
      // For now, list directory and remove audio/media files.
      
      final List<FileSystemEntity> entities = await dir.list(recursive: true).toList();
      for (final entity in entities) {
        if (entity is File) {
          final String path = entity.path;
          // Example: Only clear mp3 or wav files
          if (path.endsWith('.mp3') || path.endsWith('.wav')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
