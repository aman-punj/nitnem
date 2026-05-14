Cleanup and correct the app configuration implementation.

IMPORTANT:
The current Firestore document still contains OLD deprecated keys mixed with the new structure.

Before saving/updating config:
the system MUST sanitize/remove deprecated fields automatically.

==================================================
PROBLEM
=======

The current document still contains:

```txt id="0t8mjy"
features
forceUpdate (root level)
latestBuild
latestVersionName
minimumSupportedBuild
updateMessage
updatedAt
updatedBy
maintenanceMessage
maintenanceMode
```

These are deprecated and MUST NOT exist anymore.

==================================================
REQUIRED FIX
============

When saving config from admin panel:

1. overwrite ONLY the new structure
2. remove all deprecated keys
3. do NOT merge old + new structures
4. do NOT preserve unknown fields

==================================================
FINAL ALLOWED STRUCTURE ONLY
============================

```json id="0dpkpb"
{
  "versions": {
    "latest": 5,
    "minorUpdate": 4,
    "forceUpdate": 3
  },

  "messages": {
    "minorUpdate": {
      "title": "Update Available",
      "body": "New improvements available.",
      "primaryButton": "Update",
      "secondaryButton": "Skip for now"
    },

    "forceUpdate": {
      "title": "Update Required",
      "body": "Please update the app to continue.",
      "primaryButton": "Update App"
    },

    "maintenance": {
      "title": "Maintenance Mode",
      "body": "Bani Sagar is temporarily unavailable.",
      "primaryButton": "Close App"
    }
  },

  "maintenance": {
    "enabled": false
  },

  "storeUrl": "https://play.google.com/store/apps/details?id=com.banisagar"
}
```

==================================================
IMPORTANT
=========

Feature flags MUST be moved to:

```txt id="mjlwm7"
feature_flags/mobile
```

NOT:

```txt id="ng7f9u"
app_config/mobile
```

==================================================
SAVE BEHAVIOR
=============

The admin save logic should:

* fully replace config document
* not merge deprecated fields
* sanitize payload before upload

==================================================
ALSO FIX UPDATE FLOW
====================

The update banner/sheet is currently NOT showing.

Investigate and fix:

* version comparison logic
* build number parsing
* splash screen flow
* update trigger conditions
* config parsing
* null safety
* async loading timing

==================================================
EXPECTED BEHAVIOR
=================

If:

```txt id="zsdcr4"
currentBuild < versions.forceUpdate
```

→ force update sheet MUST appear.

If:

```txt id="rtg3uv"
currentBuild < versions.minorUpdate
```

→ optional update sheet MUST appear.

==================================================
IMPORTANT DEBUGGING
===================

Add temporary debug logs for:

* current local build
* fetched firestore versions
* parsed config
* update decision result

to verify the logic path.

Remove noisy logs afterward.
