import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_category.dart';
import '../models/content_item.dart';
import '../screens/prayer_page.dart';
import '../services/firebase_category_service.dart';
import '../services/firebase_content_service.dart';
import '../services/local_content_service.dart';
import '../services/transcript_sync_service.dart';
import '../services/shared_prefs_service.dart';

class HomeController extends GetxController {
  final FirebaseContentService _firebaseContentService;
  final FirebaseCategoryService _firebaseCategoryService;
  final LocalContentService _localContentService;
  final TranscriptSyncService _syncService;

  HomeController({
    required FirebaseContentService firebaseContentService,
    required FirebaseCategoryService firebaseCategoryService,
    required LocalContentService localContentService,
    required TranscriptSyncService syncService,
  })  : _firebaseContentService = firebaseContentService,
        _firebaseCategoryService = firebaseCategoryService,
        _localContentService = localContentService,
        _syncService = syncService;

  final RxList<ContentItem> contentItems = <ContentItem>[].obs;
  final RxList<ContentCategory> categories = <ContentCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentLang = 'pa'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLang.value = SharedPrefsService.getLanguage();
    _loadInitialContent();
  }

  Future<void> _loadInitialContent() async {
    // 1. Load from cache first
    contentItems.value = _localContentService.getCachedContentCatalog();
    
    // 2. Fetch from Firebase
    await refreshContent();
  }

  Future<void> refreshContent() async {
    isLoading.value = true;
    try {
      categories.value = await _firebaseCategoryService.fetchCategories();
      final remoteItems = await _firebaseContentService.fetchContentCatalog();
      if (remoteItems.isNotEmpty) {
        contentItems.value = remoteItems;
        await _localContentService.cacheContentCatalog(remoteItems);
        
        // Background sync for all items
        _syncAllContent(remoteItems);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, List<ContentItem>> get groupedContent {
    final grouped = <String, List<ContentItem>>{};
    for (final item in contentItems) {
      grouped.putIfAbsent(item.categoryId, () => <ContentItem>[]).add(item);
    }
    return grouped;
  }

  void _syncAllContent(List<ContentItem> items) async {
    for (var item in items) {
      if (item.type == ContentType.prayer) {
        await _syncService.syncContent(item);
      }
    }
  }

  void onContentTap(ContentItem item) async {
    if (item.type == ContentType.prayer) {
      _openPrayer(item);
    } else if (item.type == ContentType.youtube_live) {
      _openYoutube(item);
    }
  }

  void _openPrayer(ContentItem item) async {
    final localMetadata = _localContentService.getSyncMetadata(item.id);
    
    final title = item.titles.getForLanguage(currentLang.value);
    
    // Rely on synced local paths. Fallback removed as per task to remove old path assumptions.
    final audioPath = localMetadata?.audioLocalPath;
    final transcriptPath = localMetadata?.transcriptLocalPaths[currentLang.value];

    Get.to(() => PrayerPage(
          title: title,
          audioPath: audioPath ?? '',
          transcriptPath: transcriptPath ?? '',
          audioIsLocalFile: audioPath != null,
          transcriptIsLocalFile: transcriptPath != null,
          contentItem: item,
          currentLang: currentLang.value,
        ));
  }

  void _openYoutube(ContentItem item) async {
    if (item.youtubeUrl == null) return;
    final url = Uri.parse(item.youtubeUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
