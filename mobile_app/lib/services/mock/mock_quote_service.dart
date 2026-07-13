import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/quote_model.dart';
import '../quote_service.dart';

/// Drop-in replacement for [QuoteService] that reads from bundled JSON
/// fixtures instead of Firestore.
class MockQuoteService extends QuoteService {
  static const _assetPath = 'assets/mock_data/app_config__quotes.json';

  MockQuoteService() : super(firestoreInstance: null);

  @override
  Future<List<QuoteModel>> fetchQuotes() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = data['quotes'] as List<dynamic>? ?? [];

      return list
          .whereType<Map<String, dynamic>>()
          .map(QuoteModel.fromMap)
          .where((q) => q.text.isNotEmpty)
          .toList();
    } catch (_) {
      // Fallback to the hardcoded list in the parent class.
      return super.fetchQuotes();
    }
  }
}
