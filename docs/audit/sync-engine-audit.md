# Sync Engine Audit

## Overview
The application uses an "offline-first" approach. Content is managed remotely via Firebase but played entirely locally. The sync engine handles the negotiation, downloading, versioning, and local linking of audio files and transcripts.

## Core Components
- **`TranscriptSyncService`:** The primary orchestrator. Compares the remote `ContentItem` metadata with the local cache and triggers downloads if versions differ or the active track changes.
- **`TranscriptSyncEngine`:** A separate utility used primarily during playback. It utilizes a binary search algorithm (`findSegmentIndexByTime`) to map the current audio position (in seconds) to the correct transcript segment instantly.
- **`LocalContentService`:** Manages SharedPreferences caching. Stores the `LocalSyncMetadata` containing local paths to downloaded audio and transcripts.
- **`PrayerAssetService`:** Handles the physical I/O. Saves downloaded bytes to the app's document directory and generates predictable paths.

## The Sync Flow
1. **Trigger:** `PrayerController.loadContent` checks if sync is needed.
2. **Evaluation:** `TranscriptSyncService` checks `LocalSyncMetadata`. If `remote.activeTrackId` differs, or if `audio.version` / `transcript.version` is newer, it flags for download.
3. **Execution:** Downloads audio file *first*. Then downloads all available language transcripts.
4. **Persistence:** Saves bytes using `PrayerAssetService`.
5. **Metadata Update:** Updates `LocalSyncMetadata` with the new local paths and versions only if the download succeeds entirely.
6. **Playback:** Uses the local paths to initialize `just_audio` and parse the transcript JSON.

## Identified Issues & Risks
- **Error Handling & Retry:** If a download fails mid-way, there is no sophisticated retry logic. It just aborts and relies on the user reopening the page later to re-trigger the sync.
- **Storage Management:** Old track files are left on the device if the `activeTrackId` changes. The system lacks a robust garbage collection mechanism to clean up unreferenced audio/transcript files.
- **Blocking Operations:** Syncing occurs right when a user taps a prayer. If the network is slow and the file is large, it blocks the user from proceeding with a loading spinner. A background pre-fetching strategy would improve UX.
