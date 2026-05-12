import 'package:get/get.dart';
import 'package:nitnem/models/app_info_model.dart';
import 'package:nitnem/services/app_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoController extends GetxController {
  final AppInfoService service;

  final Rxn<AppInfoModel> appInfo = Rxn<AppInfoModel>();
  final RxBool isLoading = false.obs;

  AppInfoController({required this.service});

  Future<void> loadAppInfo() async {
    isLoading.value = true;
    try {
      final info = await service.fetchAppInfo();
      appInfo.value = info;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isUnderMaintenance => appInfo.value?.maintenance.isUnderMaintenance ?? false;

  String get maintenanceMessage => appInfo.value?.maintenance.maintenanceMessage ?? "System is under maintenance.";

  Future<bool> shouldForceUpdate() async {
    if (appInfo.value == null) return false;
    final packageInfo = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    return appInfo.value!.shouldForceUpdate(localBuild);
  }

  Future<bool> shouldRecommendUpdate() async {
    if (appInfo.value == null) return false;
    final packageInfo = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    return appInfo.value!.shouldRecommendUpdate(localBuild);
  }
}
