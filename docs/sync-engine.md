# Sync Engine

## Goals
- Stable subtitle highlighting for long prayers.
- O(log n) lookup per position update.
- Avoid per-line context lookup and `ensureVisible` overhead.

## Implementation
- `TranscriptSyncEngine.findSegmentIndexByTime(...)` does binary search.
- `PrayerController` listens to player position stream.
- On index change, `ScrollablePositionedList` scrolls to item by index.

## Performance Notes
- Indexed scroll avoids large GlobalKey map and context traversal.
- Only current index/highlight changes; list builds lazily.
