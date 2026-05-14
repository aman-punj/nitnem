import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';

class FirebaseContentService {
  final FirebaseFirestore _firestore;

  FirebaseContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ContentItem>> fetchContentCatalog() async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('enabled', isEqualTo: true)
          .get();

      final List<ContentItem> items = snapshot.docs
          .map((doc) => ContentItem.fromMap(doc.data()))
          .where((item) => item.titles.en.isNotEmpty) // Filter out items with empty English titles
          .toList();

      items.sort((a, b) {
        // 1. Primary sort by displayOrder (ascending)
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }

        // 2. Secondary sort by pinToTop (pinned items first)
        if (a.pinToTop != b.pinToTop) {
          return a.pinToTop ? -1 : 1;
        }

        // 3. Tertiary sort by Type priority (Prayer before YouTube)
        if (a.type != b.type) {
          return a.type == ContentType.prayer ? -1 : 1;
        }

        // 4. Alphabetical fallback (titles.en)
        return a.titles.en.compareTo(b.titles.en);
      });

      return items;
    } catch (e) {
      print('Error fetching content catalog: $e');
      return [];
    }
  }

  Future<ContentItem?> fetchContentById(String id) async {
    try {
      final doc = await _firestore.collection('content').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ContentItem.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error fetching content by id: $e');
    }
    return null;
  }
}
