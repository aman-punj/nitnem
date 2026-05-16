# Firebase Architecture Audit

## Overview
Firebase serves as the central backend for the Nitnem application, providing configuration, content management, and hosting capabilities.

## Infrastructure
- **Firebase Project:** `nitnem-39118`
- **Services Used:**
  - **Cloud Firestore:** Database for content, config, and metadata.
  - **Firebase Hosting:** Hosting for the Admin React Panel.
  - **Firebase Auth (Planned):** Mentioned in docs but not deeply integrated yet.

## Firestore Structure
### 1. `content` Collection
Stores all dynamic content items (prayers and YouTube live streams).
- **Document ID:** Unique identifier for the content.
- **Fields:**
  - `type`: `prayer` | `youtube_live`
  - `enabled`: `boolean`
  - `titles`: Map with localized titles (`en`, `pa`, `hi`).
  - `active_track`: `string` representing the current default track.
  - `tracks`: Map of track objects containing metadata and URLs for audio and transcripts. Tracks are versioned.
  - `categoryId`: Grouping category (e.g., `uncategorized`).
  - `displayOrder`: Integer for custom sorting in the app.
  - `pinToTop`: Boolean to pin items above regular items.
  - `contentPriorityType`: Priority type (`high`, `normal`, `low`).

### 2. Remote Config (Implied via Admin Panel)
Managed via Firestore or Remote Config proper (typically Firestore based on the admin setup). Stores global application parameters:
- **`app_config` (or similar document/collection):**
  - `versions`: `{ latest: int, minorUpdate: int?, forceUpdate: int? }`
  - `messages`: Customized update and maintenance prompts.
  - `maintenance`: `{ enabled: boolean }`
  - `storeUrl`: URL for app updates.

## Data Flow
1. **Admin Panel:** Modifies Firestore documents via the Web SDK.
2. **Mobile App:** Fetches content catalogs (`FirebaseContentService`) and config on startup. Caches data locally using `shared_preferences` and local file storage.

## Identified Issues & Risks
- **Asset Storage:** The application currently relies on external URLs (like Cloudinary) for audio, managed through Firestore metadata. This split can lead to broken links if the external service changes.
- **Data Duplication/Coupling:** Tracks are nested heavily inside the `content` document, which could lead to large document sizes if multiple versions/languages increase significantly.
- **Security Rules:** Needs an audit of Firestore security rules to ensure only admins can write to `content` and `config` collections, while the mobile app has read-only access.
