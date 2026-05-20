import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hukamnama_model.dart';

class HukamnamaService {
  final FirebaseFirestore _firestore;

  HukamnamaService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<HukamnamaModel?> fetchToday() async {
    try {
      final doc =
          await _firestore.collection('hukamnama').doc('today').get();
      if (!doc.exists || doc.data() == null) return null;
      return HukamnamaModel.fromMap(doc.data()!);
    } catch (e) {
      log('HukamnamaService.fetchToday error: $e');
      return null;
    }
  }
}
