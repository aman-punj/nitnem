class PrayerTrackMetadata {
  final String id;
  final String? audioUrl;
  final String? paUrl;
  final String? hiUrl;
  final String? enUrl;
  final String audioVersion;
  final String lyricsVersion;
  final bool active;

  const PrayerTrackMetadata({
    required this.id,
    required this.audioVersion,
    required this.lyricsVersion,
    this.audioUrl,
    this.paUrl,
    this.hiUrl,
    this.enUrl,
    this.active = false,
  });

  factory PrayerTrackMetadata.fromMap(Map<String, dynamic> map) {
    return PrayerTrackMetadata(
      id: (map['id'] ?? 'track_1') as String,
      audioUrl: map['audio_url'] as String?,
      paUrl: map['pa_url'] as String?,
      hiUrl: map['hi_url'] as String?,
      enUrl: map['en_url'] as String?,
      audioVersion: (map['audio_version'] ?? '1') as String,
      lyricsVersion: (map['lyrics_version'] ?? '1') as String,
      active: (map['active'] ?? false) as bool,
    );
  }
}
