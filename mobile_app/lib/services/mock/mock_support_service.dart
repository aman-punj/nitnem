import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/faq_item.dart';
import '../../models/support_request_model.dart';
import '../support_service.dart';

/// Drop-in replacement for [SupportService] that reads FAQs from
/// bundled JSON and logs support submissions to console.
class MockSupportService extends SupportService {
  static const _faqAssetPath = 'assets/mock_data/faq.json';

  MockSupportService() : super(firestore: null);

  @override
  Future<void> submitRequest(SupportRequestModel request) async {
    debugPrint('[MockSupportService] Support request submitted (not sent to Firestore):');
    debugPrint('  type: ${request.type}');
    debugPrint('  message: ${request.message}');
    debugPrint('  email: ${request.email}');
  }

  @override
  Future<List<FaqItem>> fetchEnabledFaqs() async {
    try {
      final raw = await rootBundle.loadString(_faqAssetPath);
      final list = jsonDecode(raw) as List<dynamic>;

      final items = list
          .map((e) {
            final map = e as Map<String, dynamic>;
            return FaqItem.fromMap(map['id'] as String? ?? '', map);
          })
          .where((item) => item.enabled)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      return items;
    } catch (_) {
      return const [];
    }
  }
}
