# Architecture

## Repository Structure
- `/mobile_app`: Flutter app (offline-first playback and reading).
- `/admin_panel`: React/Vite admin dashboard.
- `/shared`: Shared schemas and transcript samples.
- `/docs`: Source-of-truth technical docs.

## Mobile App
- GetX-based app with offline-first content loading: cache first, then network refresh.
- Prayer content sync persists audio/transcripts per track under local storage.
- Transcript highlighting uses `TranscriptSyncEngine` binary search and indexed scroll.
- Reading modes now support:
  - `synced` (audio + timed transcript)
  - `audioOnlyText` (audio + untimed transcript)
  - `textOnly` (manual reading)
  - focus-reading overlay (center line emphasis) is independent from timestamp sync.

## Design System Foundation
- Centralized tokens and theme under `lib/core/design_system/`:
  - `tokens/` for semantic colors, spacing, radius, typography, elevation, motion.
  - `theme/` for AMOLED-first dark theme (`AppTheme.resolve`).
  - `widgets/` for reusable primitives (`SacredCard`, `SacredTile`, `SacredAppBar`, etc.).
- Hardcoded style values should be progressively migrated to tokenized primitives.

## Dynamic Content and Categories
- Content supports `categoryId` and remains backward compatible with fallback `uncategorized`.
- Home screen groups sections dynamically by category from fetched content.
- Category metadata is fetched from Firestore `categories` collection and ordered by `displayOrder`.

## Admin Panel
- Migrated from single-screen flow to sidebar section scaffold:
  - Dashboard, Content, Categories, Feedback, Live Content, App Config, Storage, Settings.
- Content section preserves existing drag/drop ordering and edit flows.

## Backward Compatibility
- Legacy transcript JSON remains accepted.
- Existing content without `categoryId` is supported via fallback.
- Offline asset sync/version checks remain unchanged.
