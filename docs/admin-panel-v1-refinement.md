# admin-panel-v1-refinement.md

You are refining the existing Bani Sagar admin panel.

IMPORTANT:
Do NOT redesign the entire system.
Do NOT create a complex dashboard.
Do NOT add analytics-heavy enterprise UI.

The current admin panel has become:

* visually overloaded
* difficult to scan
* overly segmented
* harder to operate quickly

The goal is:

* simplify operations
* improve clarity
* reduce visual noise
* preserve premium minimalism

This is an INTERNAL developer/admin tool.

Prioritize:

* speed
* clarity
* operational confidence
* low cognitive load

NOT:

* decorative dashboard aesthetics

---

## DESIGN DIRECTION

Preserve:

* AMOLED-inspired premium dark/light aesthetic
* restrained gold accents
* soft borders
* clean typography
* minimal surfaces

Avoid:

* giant cards
* nested dashboards
* excessive explanatory text
* too many grouped containers
* enterprise analytics layouts

The UI should feel:

* calm
* operational
* modern
* lightweight
* sober

---

## SIMPLIFIED PAGE STRUCTURE

The page should contain ONLY these primary sections:

1. App Status
2. Update Control
3. Maintenance Mode
4. Feature Flags

Remove:

* unnecessary subsections
* workflow previews
* excessive labels
* decorative complexity

---

## SECTION 1 — APP STATUS

Create a very simple top summary row.

Example:

App Status      LIVE
Latest Build    6
Minimum Build   5
Maintenance     OFF

Requirements:

* compact
* glanceable
* readable
* subtle hierarchy

Avoid:

* giant metric cards
* analytics styling

---

## SECTION 2 — UPDATE CONTROL

This is the MOST important section.

Keep it extremely simple.

Fields:

* Latest Build Number
* Minimum Supported Build Number
* Latest Version Name
* Force Update Toggle
* Update Message
* Store URL

Add:
simple live status preview.

Example:

Device Build: [4]

→ FORCE UPDATE

or

→ OPTIONAL UPDATE

or

→ UP TO DATE

This should help admins instantly understand update logic.

IMPORTANT:
Do NOT overdesign this section.

---

## SECTION 3 — MAINTENANCE MODE

Simple structure only.

Fields:

* Enable Maintenance Mode
* Maintenance Message

Requirements:

* compact warning style
* restrained amber/gold emphasis
* no alarming red enterprise warnings

Avoid:

* giant warning banners
* huge modals everywhere

---

## SECTION 4 — FEATURE FLAGS

Simple toggle list.

Examples:

Punjabi Language      ON
English Language      OFF
Hindi Language        OFF
Focus Reading         OFF
New Player UI         OFF

Requirements:

* clean rows
* compact toggles
* scalable list architecture

Avoid:

* deeply nested settings
* grouped experimental dashboards

---

## FIRESTORE REQUIREMENTS

Use ONE stable document:

app_config/mobile

Example structure:

{
"latestBuild": 6,
"minimumSupportedBuild": 5,
"latestVersionName": "1.0.1",
"forceUpdate": false,
"updateMessage": "New improvements available.",
"maintenanceMode": false,
"maintenanceMessage": "",
"features": {
"punjabiLanguage": true,
"englishLanguage": false,
"focusReading": false
}
}

IMPORTANT:
Frontend and Firestore field names MUST match exactly.

---

## IMPORTANT IMPLEMENTATION REQUIREMENTS

Fix:

* Firestore data not rendering correctly
* config values not syncing
* incorrect bindings/listeners

Verify:

* correct document path
* realtime updates
* field mappings
* save/update behavior

DO NOT redesign before fixing functionality.

---

## INTERACTION RULES

Preserve:

* minimal animations
* soft transitions
* restrained focus states

Avoid:

* flashy hover states
* giant glows
* excessive motion

---

## MOST IMPORTANT GOAL

The admin panel should feel:

* operational
* fast
* simple
* predictable
* stable

NOT:

* experimental
* enterprise-heavy
* visually bloated
