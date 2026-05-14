# Future Scalability Report

## Overview
This document evaluates the Bani Sagar application's architecture against long-term goals: multi-language support, remote configuration, dynamic content types, and large user bases.

## 1. Firebase Firestore Structure
- **Current State:** Prayers and content are stored in a single `content` collection. Tracks are nested inside content documents.
- **Scalability Concern:** As the number of tracks, languages, and versions grows, document sizes will increase. Firestore has a 1MB limit per document. Fetching the entire catalog pulls all this nested data simultaneously.
- **Recommendation:** Normalize the database. Separate `Tracks` into their own collection referenced by `Content`. Implement pagination or lazy-loading for the catalog if the list of prayers/content grows significantly.

## 2. Sync & Offline Asset Management
- **Current State:** Sync happens synchronously when a user taps a prayer.
- **Scalability Concern:** With larger audio files (e.g., long paths or live recordings) and slower networks, the user is blocked. Old files are not purged.
- **Recommendation:** Implement a background sync queue using `workmanager` to pre-fetch updated content silently. Add a garbage collection service to delete orphaned files, keeping device storage low.

## 3. Multi-Language Architecture
- **Current State:** `TranscriptSegment` supports `pa`, `hi`, and `en`.
- **Scalability Concern:** Hardcoding specific languages in the model (`pa`, `hi`, `en`) does not scale if more languages (e.g., Spanish, French) are added.
- **Recommendation:** Refactor `TranscriptSegment` to use a generic Map `<String, String> translations` where keys are ISO language codes.

## 4. UI / Component Reusability
- **Current State:** The home screen list is relatively static but pulls from Firebase.
- **Scalability Concern:** The "Server-Driven UI" goal (mentioned in `PROJECT_CONTEXT.md`) requires a highly decoupled widget system that can render based on JSON schemas rather than hardcoded UI lists.
- **Recommendation:** Build an intermediate layer that translates backend `ContentItem` priorities/categories into generic "UI Sections" (e.g., Carousel, Horizontal List, Grid) that the Flutter app dynamically renders.

## 5. Admin Panel
- **Current State:** Fetches the entire collection and filters locally.
- **Scalability Concern:** If the content list exceeds a few hundred items, local filtering and rendering all items in a single view will degrade performance.
- **Recommendation:** Implement server-side pagination, searching, and virtualization for the content list in the React admin panel.
