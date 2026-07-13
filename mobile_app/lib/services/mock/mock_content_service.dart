import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/content_item.dart';
import '../firebase_content_service.dart';

/// Drop-in replacement for [FirebaseContentService] that reads from
/// bundled JSON fixtures instead of Firestore.
class MockContentService extends FirebaseContentService {
  static const _assetPath = 'assets/mock_data/content.json';

  List<ContentItem>? _cache;

  MockContentService() : super(firestore: null);

  @override
  Future<List<ContentItem>> fetchContentCatalog() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(raw) as List<dynamic>;

    _cache = list
        .map((e) => ContentItem.fromMap(e as Map<String, dynamic>))
        .where((item) => item.enabled && item.titles.en.isNotEmpty)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return _cache!;
  }

  @override
  Future<ContentItem?> fetchContentById(String id) async {
    final items = await fetchContentCatalog();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
