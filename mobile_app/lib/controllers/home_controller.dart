import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/controllers/language_controller.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_category.dart';
import '../models/content_item.dart';
import '../screens/prayer_page.dart';
import '../services/firebase_category_service.dart';
import '../services/firebase_content_service.dart';
import '../services/local_content_service.dart';
import '../services/transcript_sync_service.dart';
import '../services/analytics_service.dart';

class HomeController extends GetxController {
  final FirebaseContentService _firebaseContentService;
  final FirebaseCategoryService _firebaseCategoryService;
  final LocalContentService _localContentService;
  final TranscriptSyncService _syncService;
  final AppInfoController _appInfoController;

  HomeController({
    required FirebaseContentService firebaseContentService,
    required FirebaseCategoryService firebaseCategoryService,
    required LocalContentService localContentService,
    required TranscriptSyncService syncService,
    required AppInfoController appInfoController,
  })  : _firebaseContentService = firebaseContentService,
        _firebaseCategoryService = firebaseCategoryService,
        _localContentService = localContentService,
        _syncService = syncService,
        _appInfoController = appInfoController;

  final RxList<ContentItem> contentItems = <ContentItem>[].obs;
  final RxList<ContentCategory> categories = <ContentCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialContent();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    if (await _appInfoController.shouldRecommendUpdate()) {
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    final config = _appInfoController.appConfig.value;
    if (config == null || config.messages.minorUpdate == null) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          config.messages.minorUpdate!.title,
          style: SacredTypography.headlineMd
              .copyWith(color: const Color(0xFFF2CA50)),
        ),
        content: Text(
          config.messages.minorUpdate!.body,
          style: SacredTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(config.messages.minorUpdate!.secondaryButton ?? "Later",
                style: const TextStyle(color: Color(0xFFD0C5AF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2CA50),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              final storeUrl =
                  Platform.isIOS ? config.storeUrl.ios : config.storeUrl.android;
              final url = Uri.parse(storeUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(config.messages.minorUpdate!.primaryButton),
          ),
        ],
      ),
    );
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
    Get.find<AnalyticsService>().logPrayerOpened(
      prayerId: item.id,
      prayerName: item.titles.getForLanguage('en'),
    );

    final lang = Get.find<LanguageController>().currentLang.value;
    final localMetadata = _localContentService.getSyncMetadata(item.id);
    final title = item.titles.getForLanguage(lang);
    final audioPath = localMetadata?.audioLocalPath;
    final transcriptPath = localMetadata?.transcriptLocalPaths[lang];

    Get.to(() => PrayerPage(
          title: title,
          audioPath: audioPath ?? '',
          transcriptPath: transcriptPath ?? '',
          audioIsLocalFile: audioPath != null,
          transcriptIsLocalFile: transcriptPath != null,
          contentItem: item,
          currentLang: lang,
        ));
  }

  void _openYoutube(ContentItem item) async {
    if (item.youtubeUrl == null) return;
    final url = Uri.parse(item.youtubeUrl!);

    // Attempt to open in YouTube app, fallback to external browser
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      // Fallback: If external app launch fails, try opening in browser
      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
    }
  }
}
