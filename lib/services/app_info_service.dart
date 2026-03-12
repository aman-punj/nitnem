import '../models/app_info_model.dart';

abstract class AppInfoService {
  Future<AppInfoModel?> fetchAppInfo();

  // Future<Map<String, dynamic>> updateJsonPerPrayer(String prayerId);
}
