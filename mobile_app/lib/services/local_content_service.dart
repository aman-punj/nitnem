import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_item.dart';
import '../models/local_sync_metadata.dart';

class LocalContentService {
  static const String _keyContentCatalog = 'content_catalog';
  static const String _keySyncMetadataPrefix = 'sync_metadata_';

  final SharedPreferences _prefs;

  LocalContentService(this._prefs);

  // Content Catalog Caching
  Future<void> cacheContentCatalog(List<ContentItem> items) async {
    final list = items.map((e) => e.toMap()).toList();
    await _prefs.setString(_keyContentCatalog, jsonEncode(list));
  }

  List<ContentItem> getCachedContentCatalog() {
    final json = _prefs.getString(_keyContentCatalog);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => ContentItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
       return [];
    }
  }

  // Sync Metadata
  Future<void> saveSyncMetadata(LocalSyncMetadata metadata) async {
    await _prefs.setString(
      '$_keySyncMetadataPrefix${metadata.contentId}',
      jsonEncode(metadata.toMap()),
    );
  }

  LocalSyncMetadata? getSyncMetadata(String contentId) {
    final json = _prefs.getString('$_keySyncMetadataPrefix$contentId');
    if (json == null) return null;
    try {
      return LocalSyncMetadata.fromMap(jsonDecode(json));
    } catch (e) {
      print('Error parsing sync metadata for $contentId: $e');
      return null;
    }
  }

  Future<void> removeSyncMetadata(String contentId) async {
    await _prefs.remove('$_keySyncMetadataPrefix$contentId');
  }
}
