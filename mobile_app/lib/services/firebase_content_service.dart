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

      final items = snapshot.docs
          .map((doc) => ContentItem.fromMap(doc.data()))
          .toList();

      // Implement Priority Sorting:
      // 1. pinned content (pinToTop == true)
      // 2. manual displayOrder ascending
      // 3. prayers before youtube/live
      // 4. alphabetical fallback (titles.en)
      items.sort((a, b) {
        // 1. pinToTop
        if (a.pinToTop != b.pinToTop) {
          return a.pinToTop ? -1 : 1;
        }

        // 2. displayOrder
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }

        // 3. Type priority (Prayer > YouTube)
        if (a.type != b.type) {
          return a.type == ContentType.prayer ? -1 : 1;
        }

        // 4. Alphabetical fallback
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
