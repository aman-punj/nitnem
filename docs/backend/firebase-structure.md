# Firebase Structure

## Content Collection
`content/{contentId}`

Recommended fields:
- `id: string`
- `type: "prayer" | "youtube_live"`
- `titles: { en, pa, hi }`
- `enabled: boolean`
- `categoryId: string` (example: `nitnem`)
- `displayOrder: number`
- `pinToTop: boolean`

For prayer content:
- `active_track: string`
- `tracks: { [trackId]: { audio, transcripts } }`

## Categories Collection
`categories/{categoryId}`
- `id: string`
- `title: string`
- `displayOrder: number`
- `enabled: boolean`
- `iconKey?: string` (reserved for future dynamic icon support)

## App Config Collection
`app_config/mobile`
- `versions: { latest: number, minorUpdate: number?, forceUpdate: number? }`
- `messages: { minorUpdate: { title, body, primaryButton, secondaryButton? }?, forceUpdate: { title, body, primaryButton }?, maintenance: { title, body, primaryButton }? }`
- `maintenance: { enabled: boolean }`
- `storeUrl: string`

Update policy:
- `currentBuild < forceUpdate` => force update
- `currentBuild < minorUpdate` => recommended update
- Build number comparison only.
