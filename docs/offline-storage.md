# Offline Storage

## Strategy
- Persist audio and transcript under app documents folder:
- `prayers/{prayerId}/{trackId}/audio.mp3`
- `prayers/{prayerId}/{trackId}/transcript_{lang}.json`

## Service
- `PrayerAssetService` provides pathing and save/load helpers.
- `HomeController` prefers local files, then falls back to bundled assets.

## Versioning
- `PrayerUpdateService.syncTrackAssets` stores per-track version markers in `SharedPreferences`.
- Only changed versions are downloaded.
