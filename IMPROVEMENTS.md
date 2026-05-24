# Bani Sagar — Improvement Backlog

## High Impact

1. **Offline caching for Quotes**
   Currently if Firestore is unreachable the fallback kicks in, but the last-known server quotes are never persisted. Storing them in `SharedPreferences` alongside the other cached data means returning users always see live quotes even offline.

2. **Home screen quote widget**
   The quote is only visible deep in Settings. A subtle rotating quote card on the Home screen (below the player or in a dedicated section) would surface it where users spend most time.

3. **Audio playback analytics**
   `AnalyticsService` is registered but no events are fired for play/pause/complete on individual prayers. This data would tell you which banis are most listened to, completion rate, etc.

---

## Medium Impact

4. **Notification delivery verification**
   The FCM token is only `debugPrint`'d. A `notifications/tokens` Firestore collection tracking device tokens + last-seen timestamps would let the admin panel show how many users have notifications enabled and allow targeted sends.

5. **Pull-to-refresh on Listing screen**
   The prayer list has no refresh gesture; users have to restart the app to see newly published content.

6. **Quote multilingual support**
   The quote model only has a single `text` field. Adding `textPa` / `textHi` (matching the existing language system) would let Punjabi/Hindi users see quotes in their language.

7. **Settings screen scroll position memory**
   The list loses its scroll position on every navigation back. A `PageStorageKey` or a scroll controller held in the controller would fix this.

---

## Lower Priority / Polish

8. **Configurable splash screen duration**
   Currently hardcoded at 4 seconds. Making this a remote config value would let you tune it without a release.

9. **Admin panel dark mode**
   The admin panel has no dark theme; long editing sessions are hard on the eyes.

10. **Error boundary in admin panel**
    Any uncaught Firestore error crashes the whole panel. Wrapping sections in React error boundaries would keep the rest of the UI functional.
