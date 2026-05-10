# Architecture

## Repository Structure
- `/mobile_app`: Contains the Flutter application code.
- `/admin_panel`: Contains the React/Vite admin dashboard.
- `/shared`: Contains shared schemas and samples.
- `/docs`: Contains technical documentation.

## Mobile App
- Flutter + GetX app with prayer listing and prayer playback page.
- `just_audio` is used for playback with position stream updates.
- Transcript sync uses binary search, but old UI used `GlobalKey + ensureVisible`.
- Firebase currently provides app-level update metadata.

## Refactor Added
- Extracted `PrayerController` to `lib/controllers/prayer_controller.dart`.
- Added `TranscriptSyncEngine` for reusable binary-search sync logic.
- Switched transcript list to `scrollable_positioned_list` for scalable indexed scrolling.
- Added `PrayerAssetService` for durable offline prayer audio/transcript files.

## Backward Compatibility
- If local files do not exist, app continues using bundled assets.
- Existing transcript JSON with `segments` remains supported.
