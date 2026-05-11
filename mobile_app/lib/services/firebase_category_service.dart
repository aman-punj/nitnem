import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/content_category.dart';

class FirebaseCategoryService {
  final FirebaseFirestore _firestore;

  FirebaseCategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ContentCategory>> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('enabled', isEqualTo: true)
          .get();

      final categories = snapshot.docs
          .map((doc) => ContentCategory.fromMap(doc.data()))
          .toList();

      categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return categories;
    } catch (_) {
      return const [];
    }
  }
}
