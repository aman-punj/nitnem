class LocalSyncMetadata {
  final String contentId;
  final String activeTrackId;
  final int audioVersion;
  final Map<String, int> transcriptVersions;
  final String? audioLocalPath;
  final Map<String, String> transcriptLocalPaths;
  final int lastSyncedAt;

  const LocalSyncMetadata({
    required this.contentId,
    required this.activeTrackId,
    this.audioVersion = 0,
    this.transcriptVersions = const {},
    this.audioLocalPath,
    this.transcriptLocalPaths = const {},
    this.lastSyncedAt = 0,
  });

  factory LocalSyncMetadata.fromMap(Map<String, dynamic> map) {
    return LocalSyncMetadata(
      contentId: map['content_id'] ?? '',
      activeTrackId: map['active_track_id'] ?? '',
      audioVersion: map['audio_version'] ?? 0,
      transcriptVersions: Map<String, int>.from(map['transcript_versions'] ?? {}),
      audioLocalPath: map['audio_local_path'],
      transcriptLocalPaths: Map<String, String>.from(map['transcript_local_paths'] ?? {}),
      lastSyncedAt: map['last_synced_at'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content_id': contentId,
      'active_track_id': activeTrackId,
      'audio_version': audioVersion,
      'transcript_versions': transcriptVersions,
      'audio_local_path': audioLocalPath,
      'transcript_local_paths': transcriptLocalPaths,
      'last_synced_at': lastSyncedAt,
    };
  }

  LocalSyncMetadata copyWith({
    String? contentId,
    String? activeTrackId,
    int? audioVersion,
    Map<String, int>? transcriptVersions,
    String? audioLocalPath,
    Map<String, String>? transcriptLocalPaths,
    int? lastSyncedAt,
  }) {
    return LocalSyncMetadata(
      contentId: contentId ?? this.contentId,
      activeTrackId: activeTrackId ?? this.activeTrackId,
      audioVersion: audioVersion ?? this.audioVersion,
      transcriptVersions: transcriptVersions ?? this.transcriptVersions,
      audioLocalPath: audioLocalPath ?? this.audioLocalPath,
      transcriptLocalPaths: transcriptLocalPaths ?? this.transcriptLocalPaths,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
