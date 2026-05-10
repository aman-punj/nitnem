# Transcript Format

## Canonical Segment
```json
{
  "start": 9.16,
  "end": 10.45,
  "pa": "??? ??? ?????? ??? ?",
  "hi": "",
  "en": "",
  "flagged": false
}
```

## Rules
- `end` equals next segment `start`.
- Final segment may use `start + fallbackSeconds` if unknown.
- `pa` is required; `hi` and `en` are optional.

## Compatibility
- Legacy `text` field is still accepted and mapped to `pa`.
- Both `{ "segments": [...] }` and bare `[...]` JSON arrays are parsed.
