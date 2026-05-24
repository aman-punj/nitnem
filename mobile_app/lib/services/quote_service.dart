import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/quote_model.dart';

class QuoteService {
  static const _fallback = [
    QuoteModel(text: 'Truth is the highest virtue, but higher still is truthful living.'),
    QuoteModel(text: 'In the ambrosial hours of the early morning, meditate and contemplate the True Name.'),
    QuoteModel(text: 'One who serves becomes one with the Lord.'),
    QuoteModel(text: 'Within the heart, the Name of the Lord abides.'),
  ];

  final FirebaseFirestore _firestore;

  QuoteService({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<List<QuoteModel>> fetchQuotes() async {
    try {
      final doc = await _firestore.collection('app_config').doc('quotes').get();
      if (doc.exists && doc.data() != null) {
        final raw = doc.data()!['quotes'] as List<dynamic>?;
        if (raw != null && raw.isNotEmpty) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(QuoteModel.fromMap)
              .where((q) => q.text.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('QuoteService fetch error: $e');
    }
    return _fallback;
  }
}
