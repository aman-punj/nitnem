import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/hukamnama_model.dart';
import '../hukamnama_service.dart';

/// Drop-in replacement for [HukamnamaService] that reads from bundled
/// JSON fixtures instead of Firestore + SGPC scraping.
class MockHukamnamaService extends HukamnamaService {
  static const _assetPath = 'assets/mock_data/hukamnama__today.json';

  MockHukamnamaService() : super(firestoreInstance: null);

  @override
  Future<HukamnamaModel?> fetchToday({String backendUrl = ''}) async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return HukamnamaModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }
}
