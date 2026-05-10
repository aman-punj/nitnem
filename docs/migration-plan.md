# Migration Plan

## Phase 1 (Completed)
- Keep existing prayer playback flow.
- Move sync logic into reusable controller/service.
- Replace GlobalKey-based scrolling with indexed list scrolling.
- Add local prayer asset pathing with fallback.

## Phase 2 (Completed)
- Repo structure reorganized to `/mobile_app`, `/admin_panel`, `/shared`, `/docs`.
- Root `firebase.json` and `.gitignore` updated.
- Shared transcript samples added.

## Phase 3
- Expand Firebase prayer/track metadata reads in mobile bootstrap.
- Download active track assets and versions on startup.
- Support language flags from remote config/app settings.

## Phase 4 (Dynamic Content Migration)
- **Identify Hardcoded Data**: `HomeController.baniList` in `mobile_app/lib/controllers/home_controller.dart` is currently hardcoded.
- **Goal**: Transition to server-driven content catalog.
- **Action**: Create a `ContentService` that fetches prayer list from Firestore.
- **Action**: Implement track versioning and auto-update logic.
- **Action**: Support new content types (youtube_live).
