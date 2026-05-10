import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/content_item.dart';
import '../models/local_sync_metadata.dart';
import 'local_content_service.dart';
import 'prayer_asset_service.dart';

class TranscriptSyncService {
  final LocalContentService _localContentService;
  final PrayerAssetService _assetService;

  TranscriptSyncService(this._localContentService, this._assetService);

  Future<void> syncContent(ContentItem remote) async {
    if (remote.type != ContentType.prayer) return;

    final local = _localContentService.getSyncMetadata(remote.id) ??
        LocalSyncMetadata(contentId: remote.id, activeTrackId: '');

    final activeTrack = remote.tracks[remote.activeTrackId];
    if (activeTrack == null) return;

    bool needsAudio = false;
    bool needsTranscripts = false;

    // 1. Check if track changed
    if (local.activeTrackId != remote.activeTrackId) {
      needsAudio = true;
      needsTranscripts = true;
    } else {
      // Check versions
      if (activeTrack.audio != null && activeTrack.audio!.version > local.audioVersion) {
        needsAudio = true;
      }
      activeTrack.transcripts.forEach((lang, file) {
        if (file.version > (local.transcriptVersions[lang] ?? 0)) {
          needsTranscripts = true;
        }
      });
    }

    if (!needsAudio && !needsTranscripts) {
      // Check if files actually exist
      if (activeTrack.audio != null) {
        final audioFile = await _assetService.existingAudio(prayerId: remote.id, trackId: activeTrack.id);
        if (audioFile == null) needsAudio = true;
      }
      for (var lang in activeTrack.transcripts.keys) {
        final transFile = await _assetService.existingTranscript(
          prayerId: remote.id,
          languageCode: lang,
          trackId: activeTrack.id,
        );
        if (transFile == null) needsTranscripts = true;
      }
    }

    if (!needsAudio && !needsTranscripts) return;

    try {
      String? newAudioPath = local.audioLocalPath;
      Map<String, int> newTranscriptVersions = Map.from(local.transcriptVersions);
      Map<String, String> newTranscriptPaths = Map.from(local.transcriptLocalPaths);

      // 1. Download Audio FIRST
      if (needsAudio && activeTrack.audio != null) {
        final audioResponse = await http.get(Uri.parse(activeTrack.audio!.url));
        if (audioResponse.statusCode == 200) {
          await _assetService.saveAudioBytes(
            prayerId: remote.id,
            trackId: activeTrack.id,
            bytes: audioResponse.bodyBytes,
          );
          newAudioPath = await _assetService.audioPath(prayerId: remote.id, trackId: activeTrack.id);
        } else {
          throw Exception('Failed to download audio for ${remote.id}');
        }
      }

      // 2. Download Transcripts
      if (needsTranscripts) {
        for (var entry in activeTrack.transcripts.entries) {
          final lang = entry.key;
          final file = entry.value;

          if (needsAudio || file.version > (local.transcriptVersions[lang] ?? 0)) {
            final transResponse = await http.get(Uri.parse(file.url));
            if (transResponse.statusCode == 200) {
              await _assetService.saveTranscript(
                prayerId: remote.id,
                languageCode: lang,
                trackId: activeTrack.id,
                content: transResponse.body,
              );
              newTranscriptVersions[lang] = file.version;
              newTranscriptPaths[lang] = await _assetService.transcriptPath(
                prayerId: remote.id,
                languageCode: lang,
                trackId: activeTrack.id,
              );
            }
          }
        }
      }

      // 3. Update Metadata ONLY after success
      final updatedLocal = local.copyWith(
        activeTrackId: remote.activeTrackId,
        audioVersion: activeTrack.audio?.version ?? 0,
        transcriptVersions: newTranscriptVersions,
        audioLocalPath: newAudioPath,
        transcriptLocalPaths: newTranscriptPaths,
        lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _localContentService.saveSyncMetadata(updatedLocal);

      // 4. Cleanup old track audio if track changed
      if (local.activeTrackId.isNotEmpty && local.activeTrackId != remote.activeTrackId) {
        // Optional: Implement cleanup of old track files
        // For now, they stay in the 'prayers' directory under different track IDs
      }

    } catch (e) {
      print('Sync failed for ${remote.id}: $e');
      // We don't update metadata, so it will retry next time
    }
  }
}
