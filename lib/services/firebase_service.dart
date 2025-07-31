import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_info_model.dart';
import 'app_info_service.dart';

class FirebaseAppInfoService implements AppInfoService {
  final FirebaseFirestore firestore;

  FirebaseAppInfoService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  @override
  Future<AppInfoModel?> fetchAppInfo() async {
    try {
      final doc = await firestore
          .collection('app_info')
          .doc('XRW0TNK0gtC6FOhMicb9')
          .get();

      // final patchDoc = await
      //     .collection('app_info')
      //     .doc('XRW0TNK0gtC6FOhMicb9')
      //     .get();
      //
      // if (patchDoc.exists) {
      //   final patchData = patchDoc.data();
      //   print(patchData);
      // }

      if ( doc.data() != null) {
        return AppInfoModel.fromMap(doc.data()!);
      }
    } catch (e) {
      log(e.toString());}
    return null;
  }

  @override
  Future<Map<String, dynamic>> updateJsonPerPrayer(String prayerId) {
    // TODO: implement updateJsonPerPrayer
    throw UnimplementedError();
  }
}
