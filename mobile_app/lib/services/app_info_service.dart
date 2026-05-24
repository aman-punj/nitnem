import '../models/app_config_model.dart';
import '../models/developer_support_model.dart';
import '../models/feature_flags_model.dart';

abstract class AppInfoService {
  Future<AppConfig?> fetchAppInfo();
  Future<FeatureFlags?> fetchFeatureFlags();
  Future<Menu?> fetchMenuSettings();
  Future<DeveloperSupport?> fetchDeveloperSupport();
}

  // Future<Map<String, dynamic>> updateJsonPerPrayer(String prayerId);

