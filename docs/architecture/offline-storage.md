# Offline Storage

## Strategy
- Persist audio and transcript files under app documents directory.
- Cache content catalog in local storage before remote refresh.

## Paths
- `prayers/{contentId}/{trackId}/audio.mp3`
- `prayers/{contentId}/{trackId}/transcript_{lang}.json`

## Metadata
- Sync metadata stores active track, local paths, and per-file versions.
- Version comparisons drive download decisions to avoid redundant transfers.

## Compatibility and Dynamic Data
- Content without `categoryId` uses `uncategorized` fallback.
- Home grouping is dynamic but local catalog behavior remains offline-first.
