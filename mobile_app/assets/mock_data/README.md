# Mock Data Fixtures

This directory contains JSON files that mirror the Firebase Firestore documents
used by the mobile app. When `kUseMockData` is set to `true` in
`lib/core/utils/mock_config.dart`, the app reads from these files instead of
hitting Firebase prod.

## How to update

1. Open Firebase Console → Firestore Database
2. Navigate to the collection/document listed below
3. Copy the document data as JSON
4. Paste it into the corresponding file here
5. Hot-restart the app to pick up changes

## File → Firestore mapping

| File | Firestore path | Description |
|---|---|---|
| `content.json` | `content` collection (where `enabled == true`) | Array of content items |
| `categories.json` | `categories` collection (where `enabled == true`) | Array of category objects |
| `app_config__mobile.json` | `app_config/mobile` doc | App version, maintenance, features |
| `app_config__settings.json` | `app_config/settings` doc | Menu configuration |
| `app_config__developer_support.json` | `app_config/developer_support` doc | UPI / Ko-fi links |
| `app_config__quotes.json` | `app_config/quotes` doc | Rotating quote list |
| `hukamnama__today.json` | `hukamnama/today` doc | Daily Hukamnama |
| `faq.json` | `faq` collection | FAQ items |

## Notes

- Audio/transcript URLs use `https://mock.local/` — these won't resolve. The
  app's offline fallback handles missing files gracefully.
- To test with real audio, paste actual Cloudinary URLs from Firebase into the
  `tracks.*.audio.url` fields in `content.json`.
- The `hukamnama__today.json` date field is static. Update it to today's date
  if you want to test the "is today" logic.
