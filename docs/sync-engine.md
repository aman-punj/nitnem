# Sync Engine

## Goals
- Stable highlight updates for long transcripts.
- O(log n) lookup via binary search.
- Preserve smooth scrolling and avoid GlobalKey-heavy layouts.

## Implementation
- `TranscriptSyncEngine.findSegmentIndexByTime(...)` powers synced mode.
- Controller auto-scroll uses `ScrollablePositionedList` index-based movement.
- Focus reading mode is viewport-center based and does not depend on timestamps.

## Mode Handling
- If audio + timed transcript: synced mode enabled.
- If audio + untimed transcript: plain reading with audio enabled.
- If transcript only: text mode enabled.

## Performance Notes
- Indexed scrolling and minimal reactive state updates are preserved.
- Focus mode uses subtle animated opacity and center-index tracking only.
