Implement the remaining core Settings functionalities for the Nitnem app using scalable architecture and production-ready Flutter practices.

Current Context:

* Settings UI redesign already completed
* Frontend groups settings by sections
* Firestore controls enabledItems visibility only
* Flutter app uses GetX
* Existing language switching already exists
* Existing audio playback implementation already exists
* Existing feedback screen already exists
* Existing settings architecture:

  * DrawerMenuItem enum
  * SettingsSection
  * SettingsItemType
  * FrostedSettingsCard
  * SettingsTile

Goal:
Implement the actual settings functionalities cleanly with scalable local persistence and service architecture.

IMPORTANT:
Do NOT overengineer.
Focus only on practical production-ready functionality needed right now.

---

## ARCHITECTURE REQUIREMENTS

Create clean separation between:

* UI
* state management
* persistence
* services

Create:

* SettingsController
* SettingsRepository
* ThemeService
* NotificationService
* CacheService

Use GetX properly.

Avoid business logic inside UI widgets.

---

## LOCAL STORAGE

Use local persistence for settings.

Acceptable:

* SharedPreferences for now
  OR
* Hive if already available

Persist:

* theme mode
* font scale
* keep screen awake
* notification preferences

Structure code so storage can later migrate easily.

---

## THEME FUNCTIONALITY

Implement:

* Dark
* Light
* System

Requirements:

* app-wide theme switching
* reactive updates
* persistent across app restarts
* integrated with GetX

Use:
Get.changeThemeMode(...)

Theme selector should feel premium and polished.

---

## TYPOGRAPHY SIZE FUNCTIONALITY

Implement:

* global font scaling
* persistent storage
* reactive updates

Requirements:

* typography affects entire app
* restore on app launch
* use existing FontSizeController

Slider should:

* update live
* persist automatically
* show smooth behavior

Preview Gurbani text should scale correctly.

---

## LANGUAGE FUNCTIONALITY

Connect existing language switching logic.

Requirements:

* navigation works correctly
* maintain existing implementation
* avoid duplicate language systems

---

## NOTIFICATIONS FUNCTIONALITY

Create proper NotificationSettingsScreen.

Implement:

1. Morning Nitnem Reminder
2. Evening Nitnem Reminder
3. Daily Hukamnama Push toggle

Requirements:

* local settings persistence
* clean UI
* scalable architecture
* toggles reactive

Morning/Evening reminders:

* local notifications only
* configurable time picker
* scheduled notifications

Hukamnama:

* prepare toggle only
* FCM integration can be placeholder for now

Use:
flutter_local_notifications

Structure:
NotificationService handles scheduling logic.

---

## KEEP SCREEN AWAKE

Implement using:
wakelock_plus

Requirements:

* enable during paath
* persistent preference
* toggle from settings
* integrated with GetX

Use:
WakelockPlus.enable()
WakelockPlus.disable()

---

## CLEAR CACHE FUNCTIONALITY

Implement proper cache clearing.

Requirements:

* clear downloaded bani/audio/media only
* DO NOT clear:

  * settings
  * bookmarks
  * preferences
  * reading state

Create:
CacheService

Behavior:

* show confirmation dialog
* show loading state
* show success snackbar

Downloaded content should automatically redownload later when needed.

---

## SHARE APP

Connect existing ShareService properly.

Requirements:

* native share sheet
* production-safe behavior

---

## FEEDBACK / REPORT ISSUE

Reuse existing FeedbackScreen.

Requirements:

* pass feedback type dynamically
* support:

  * Send Feedback
  * Report Issue

Firestore save logic can remain TODO.

---

## FAQ / PRIVACY POLICY

Implement placeholder navigation/pages.

Requirements:

* clean scaffold pages
* architecture ready
* dummy content acceptable

---

## SETTINGS CONTROLLER

Create centralized SettingsController.

Should manage:

* theme mode
* keep awake
* notification states
* font scale
* local persistence triggers

Reactive and scalable.

---

## UX REQUIREMENTS

Settings should feel:

* responsive
* smooth
* premium
* calm
* reliable

Requirements:

* proper loading states
* smooth reactive updates
* no UI flicker
* graceful error handling
* snackbars/dialogs where needed

---

## IMPORTANT AUDIO UX RULE

Audio playback:

* may continue in device background
* may continue on lock screen

BUT:

* no global in-app mini player
* no persistent controls outside prayer page

Playback controls remain contextual.

---

## CODE QUALITY

Requirements:

* clean architecture friendly
* modular
* reusable
* scalable
* production-ready
* avoid duplicated logic
* avoid giant controllers
* avoid UI business logic
* proper service abstraction
* maintainable long-term

---

## DO NOT IMPLEMENT YET

Avoid:

* backend-driven UI rendering
* remote settings sync
* advanced analytics
* multi-device sync
* download management system
* realtime config sync
* premium feature gating

Keep implementation practical and focused for current app scale.
