import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/content_category.dart';
import '../firebase_category_service.dart';

/// Drop-in replacement for [FirebaseCategoryService] that reads from
/// bundled JSON fixtures instead of Firestore.
class MockCategoryService extends FirebaseCategoryService {
  static const _assetPath = 'assets/mock_data/categories.json';

  List<ContentCategory>? _cache;

  MockCategoryService() : super(firestore: null);

  @override
  Future<List<ContentCategory>> fetchCategories() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(raw) as List<dynamic>;

    _cache = list
        .map((e) => ContentCategory.fromMap(e as Map<String, dynamic>))
        .where((c) => c.enabled)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return _cache!;
  }
}
