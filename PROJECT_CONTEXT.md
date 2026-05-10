# Nitnem Project Context

## Overview

Nitnem is a Sikh prayer application with:

* offline-first audio playback
* synchronized prayer lyrics
* future multi-language support
* remotely updateable content
* React-based admin panel

The architecture is content-driven.

---

## Repository Structure

* `/mobile_app`: Flutter mobile application
* `/admin_panel`: React/Vite administration dashboard
* `/shared`: Shared schemas, examples, and transcript samples
* `/docs`: Technical documentation
* `firebase.json`: Firebase configuration (root)
* `PROJECT_CONTEXT.md`: This file (AI memory)

---

## Mobile Stack

* Flutter
* GetX
* just_audio
* Firebase Firestore
* Cloudinary audio hosting

---

## Admin Stack

* React + Vite
* Firebase Auth
* Firebase Firestore
* Cloudinary uploads

---

## Current Transcript Format

Input format:

[00:09.16]ਆਦਿ ਸਚੁ ਜੁਗਾਦਿ ਸਚੁ ॥

Parsed format:

[
{
"start": 9.16,
"end": 10.45,
"pa": "ਆਦਿ ਸਚੁ ਜੁਗਾਦਿ ਸਚੁ ॥",
"hi": "",
"en": ""
}
]

Rules:

* end = next segment start
* Punjabi currently enabled
* Hindi/English planned later

---

## Architecture Decisions

* Audio files are downloaded permanently locally
* Audio is NOT streamed
* Cloudinary hosts audio
* Firebase stores metadata/config
* Multi-language support planned
* Dynamic content system planned
* Home screen should eventually become server-driven

---

## Current Improvements Already Implemented

* Transcript parser abstraction
* Transcript sync engine
* ScrollablePositionedList migration
* Offline asset service
* Track metadata model
* Prayer update service
* React admin panel scaffold
* Timing tool scaffold
* Env infrastructure
* Firebase env config abstraction

---

## Important Rules

* Do NOT run flutter analyze automatically
* Do NOT rewrite existing playback logic unnecessarily
* Prefer incremental refactors
* Keep Flutter widgets modular
* Avoid GlobalKey-heavy scrolling
* Prefer indexed scrolling approaches

---

## Pending Work

* Firebase auth UI
* Cloudinary upload flow
* Firestore content management
* Dynamic prayer catalog
* Transcript timing workflow improvements
* Offline asset syncing refinement
* Feature flags
* Multi-language transcript support

---

## Long-Term Goal

The app should support:

* remotely configurable prayers
* multiple tracks per prayer
* youtube live content
* dynamic content types
* offline-first playback
* synchronized multilingual subtitles
