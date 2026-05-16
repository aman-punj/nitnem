import 'package:get/get.dart';
import 'package:nitnem/models/app_config_model.dart';
import 'package:nitnem/services/app_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoController extends GetxController {
  final AppInfoService service;

  final Rxn<AppConfig> appConfig = Rxn<AppConfig>();
  final Rxn<Menu> menuConfig = Rxn<Menu>();
  // final Rxn<FeatureFlags> featureFlags = Rxn<FeatureFlags>();
  final RxBool isLoading = false.obs;

  AppInfoController({required this.service});

  Future<void> loadAppInfo() async {
    isLoading.value = true;
    try {
      final config = await service.fetchAppInfo();
      // final flags = await service.fetchFeatureFlags();
      final menu = await service.fetchMenuSettings();
      appConfig.value = config;
      // featureFlags.value = flags;
      menuConfig.value = menu;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isUnderMaintenance => appConfig.value?.maintenance.enabled ?? false;

  Future<int> _getLocalBuild() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.tryParse(packageInfo.buildNumber) ?? 0;
  }

  Future<bool> shouldForceUpdate() async {
    final config = appConfig.value;
    if (config == null || config.versions.forceUpdate == null) return false;
    final localBuild = await _getLocalBuild();
    final should = localBuild < config.versions.forceUpdate!;
    return should;
  }

  Future<bool> shouldRecommendUpdate() async {
    final config = appConfig.value;
    if (config == null || config.versions.minorUpdate == null) return false;
    final localBuild = await _getLocalBuild();
    return localBuild < config.versions.minorUpdate!;
  }
}
