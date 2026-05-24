# Bani Sagar — Improvement Backlog

## High Impact

1. **Offline caching — DONE**
   Quotes are now persisted in SharedPreferences and served from cache when Firestore is unreachable. Content catalog was already cached via LocalContentService. On the first ever install with no internet a bottom-sheet prompts the user to connect. Attempting to play a prayer or open a YouTube video while offline shows a snackbar. `ConnectivityService` (connectivity_plus) monitors network state app-wide.

2. **Home screen quote widget — DONE**
   A compact quote strip now appears at the bottom of the Home screen, above the mini-player. It always shows a *different* quote from the one in Settings — both are drawn from a freshly shuffled list on every app launch.

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

8. **Splash screen duration — DONE**
   Now connectivity-aware: when online the splash exits as soon as all startup tasks finish (minimum 0.5 s, maximum 4 s cap). When offline or on a very slow connection it waits the full 4 s then proceeds with cached data.

9. **Admin panel dark mode**
   The admin panel has no dark theme; long editing sessions are hard on the eyes.

10. **Error boundary in admin panel**
    Any uncaught Firestore error crashes the whole panel. Wrapping sections in React error boundaries would keep the rest of the UI functional.
