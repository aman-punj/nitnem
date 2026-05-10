# Migration Plan

## Phase 1 (Completed in this change)
- Keep existing prayer playback flow.
- Move sync logic into reusable controller/service.
- Replace GlobalKey-based scrolling with indexed list scrolling.
- Add local prayer asset pathing with fallback.

## Phase 2
- Expand Firebase prayer/track metadata reads in mobile bootstrap.
- Download active track assets and versions on startup.
- Support language flags from remote config/app settings.

## Phase 3
- Move repo to target structure:
  - `mobile_app/`
  - `admin_panel/`
  - `shared/`
  - `docs/`
- Share transcript schema/types between Flutter and admin tooling.
