import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitnem/models/faq_item.dart';
import 'package:nitnem/models/privacy_policy_content.dart';
import 'package:nitnem/models/support_request_model.dart';

class SupportService {
  SupportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitRequest(SupportRequestModel request) async {
    await _firestore.collection('support_requests').add({
      ...request.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<FaqItem>> fetchEnabledFaqs() async {
    try {
      final snapshot = await _firestore
          .collection('faq')
          .where('enabled', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => FaqItem.fromMap(doc.id, doc.data()))
          .toList(growable: false);
    } catch (_) {
      // Fallback avoids requiring a composite index while preserving behavior.
      final snapshot = await _firestore.collection('faq').get();
      final items = snapshot.docs
          .map((doc) => FaqItem.fromMap(doc.id, doc.data()))
          .where((item) => item.enabled)
          .toList(growable: false);
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    }
  }

  Future<PrivacyPolicyContent> fetchPrivacyPolicy() async {
    final doc = await _firestore
        .collection('app_content')
        .doc('privacy_policy')
        .get();

    if (!doc.exists || doc.data() == null) {
      return const PrivacyPolicyContent(title: 'Privacy Policy', content: '');
    }

    return PrivacyPolicyContent.fromMap(doc.data()!);
  }
}
