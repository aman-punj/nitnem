import 'package:get/get.dart';
import 'package:nitnem/models/app_info_model.dart';
import 'package:nitnem/services/app_info_service.dart';

class AppInfoController extends GetxController {
  final AppInfoService service;

  AppInfoController({required this.service});

  Future<AppInfoModel?> loadAppInfo() async {
    return await service.fetchAppInfo();
  }
}
