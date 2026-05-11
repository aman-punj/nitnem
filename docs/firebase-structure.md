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
- `latestBuild: number`
- `minimumSupportedBuild: number`
- `forceUpdate: boolean`
- `updateMessage: string`

Update policy:
- `currentBuild < minimumSupportedBuild` => force update
- `currentBuild < latestBuild` => recommended update
- Build number comparison only (no semantic-version string comparison)
