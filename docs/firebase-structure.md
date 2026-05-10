# Firebase Structure

## Recommended
```
prayers/{prayerId}/tracks/{trackId}
  audio_url: string
  pa_url: string
  hi_url: string
  en_url: string
  audio_version: string
  lyrics_version: string
  active: boolean
```

## Notes
- `active=true` marks default track for mobile clients.
- Audio and lyrics versions are independent.
- Mobile compares versions before downloading.
