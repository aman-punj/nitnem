import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preference_module.dart';

class PreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PreferenceModule>> getPreferenceModules() async {
    try {
      final snapshot = await _firestore
          .collection('preference_modules')
          .where('enabled', isEqualTo: true)
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        return _getDefaultModules();
      }

      return snapshot.docs
          .map((doc) => PreferenceModule.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching preference modules: $e');
      return _getDefaultModules();
    }
  }

  List<PreferenceModule> _getDefaultModules() {
    return [
      const PreferenceModule(
        id: 'theme',
        enabled: true,
        order: 1,
        title: 'Theme',
        description: 'Customize visual appearance',
        icon: 'palette',
        type: PreferenceModuleType.bottomSheet,
        event: 'open_theme_settings',
      ),
      const PreferenceModule(
        id: 'font_size',
        enabled: true,
        order: 2,
        title: 'Reading Size',
        description: 'Adjust Gurbani typography size',
        icon: 'format_size',
        type: PreferenceModuleType.slider,
        event: 'adjust_font_size',
      ),
      const PreferenceModule(
        id: 'feedback',
        enabled: true,
        order: 3,
        title: 'Feedback',
        description: 'Share your experience',
        icon: 'feedback',
        type: PreferenceModuleType.navigation,
        event: 'open_feedback',
      ),
      const PreferenceModule(
        id: 'offline_storage',
        enabled: true,
        order: 4,
        title: 'Offline Sanctuary',
        description: 'Manage downloaded content',
        icon: 'cloud_download',
        type: PreferenceModuleType.navigation,
        event: 'open_storage_management',
      ),
      const PreferenceModule(
        id: 'about',
        enabled: true,
        order: 5,
        title: 'About Bani Sagar',
        description: 'Learn about the platform',
        icon: 'info',
        type: PreferenceModuleType.navigation,
        event: 'open_about',
      ),
    ];
  }
}
