enum ContentType { prayer, youtube_live }

class LocalizedTitles {
  final String en;
  final String pa;
  final String hi;

  const LocalizedTitles({
    required this.en,
    required this.pa,
    required this.hi,
  });

  factory LocalizedTitles.fromMap(Map<String, dynamic> map) {
    return LocalizedTitles(
      en: map['en'] ?? '',
      pa: map['pa'] ?? '',
      hi: map['hi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'en': en,
      'pa': pa,
      'hi': hi,
    };
  }

  String getForLanguage(String languageCode) {
    switch (languageCode) {
      case 'pa':
      case 'pn':
        return pa;
      case 'hi':
        return hi;
      case 'en':
      default:
        return en;
    }
  }
}

class VersionedFile {
  final String url;
  final int version;

  const VersionedFile({
    required this.url,
    required this.version,
  });

  factory VersionedFile.fromMap(Map<String, dynamic> map) {
    return VersionedFile(
      url: map['url'] ?? '',
      version: map['version'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'version': version,
    };
  }
}

class PrayerTrack {
  final String id;
  final String title;
  final VersionedFile? audio;
  final Map<String, VersionedFile> transcripts;

  const PrayerTrack({
    required this.id,
    required this.title,
    this.audio,
    required this.transcripts,
  });

  factory PrayerTrack.fromMap(Map<String, dynamic> map) {
    final transcriptMap = <String, VersionedFile>{};
    if (map['transcripts'] != null) {
      (map['transcripts'] as Map<String, dynamic>).forEach((key, value) {
        transcriptMap[key] = VersionedFile.fromMap(value);
      });
    }

    return PrayerTrack(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      audio: map['audio'] != null ? VersionedFile.fromMap(map['audio']) : null,
      transcripts: transcriptMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audio': audio?.toMap(),
      'transcripts':
          transcripts.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}

class ContentItem {
  final String id;
  final ContentType type;
  final LocalizedTitles titles;
  final bool enabled;
  final String activeTrackId;
  final Map<String, PrayerTrack> tracks;
  final String? youtubeUrl;
  final String? thumbnail;
  final String? iconUrl;
  final String? iconKey;
  final String categoryId;
  final int displayOrder;

  const ContentItem({
    required this.id,
    required this.type,
    required this.titles,
    required this.enabled,
    this.activeTrackId = '',
    this.tracks = const {},
    this.youtubeUrl,
    this.thumbnail,
    this.iconUrl,
    this.iconKey,
    this.categoryId = 'uncategorized',
    this.displayOrder = 100,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String?;
    final type = typeStr == 'youtube_live'
        ? ContentType.youtube_live
        : ContentType.prayer;

    final trackMap = <String, PrayerTrack>{};
    if (map['tracks'] != null) {
      (map['tracks'] as Map<String, dynamic>).forEach((key, value) {
        trackMap[key] = PrayerTrack.fromMap(value);
      });
    }

    return ContentItem(
      id: map['id'] ?? '',
      type: type,
      titles: LocalizedTitles.fromMap(map['titles'] ?? {}),
      enabled: map['enabled'] ?? true,
      activeTrackId: map['active_track'] ?? '',
      tracks: trackMap,
      youtubeUrl: map['youtube_url'],
      thumbnail: map['thumbnail'],
      iconUrl: map['iconUrl'] as String?,
      iconKey: map['iconKey'] as String?,
      categoryId: map['categoryId'] ?? 'uncategorized',
      displayOrder: map['displayOrder'] ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == ContentType.youtube_live ? 'youtube_live' : 'prayer',
      'titles': titles.toMap(),
      'enabled': enabled,
      'active_track': activeTrackId,
      'tracks': tracks.map((key, value) => MapEntry(key, value.toMap())),
      'youtube_url': youtubeUrl,
      'thumbnail': thumbnail,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (iconKey != null) 'iconKey': iconKey,
      'categoryId': categoryId,
      'displayOrder': displayOrder,
    };
  }
}
