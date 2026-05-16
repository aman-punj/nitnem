# Transcript Format

## Unified Segment Shape
```json
{
  "text": "???? ???? ? ????",
  "startTime": null,
  "endTime": null,
  "pa": "???? ???? ? ????",
  "hi": "",
  "en": "",
  "flagged": false
}
```

## Timed vs Untimed
- Timed segment: `startTime` and `endTime` are numbers.
- Untimed segment: `startTime` / `endTime` are `null`.
- Single schema supports synced mode and plain/focus reading mode.

## Compatibility
- Legacy keys (`start`, `end`, `text`) are still parsed.
- Both `{ "segments": [...] }` and bare `[...]` arrays remain supported.
- `pa` stays the canonical primary transcript field.
