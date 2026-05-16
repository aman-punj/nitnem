# Nitnem Project Context

This document provides a high-level overview of the Nitnem project, designed to help new developers and AI agents quickly understand the system's purpose, structure, and key architectural principles.

## Purpose
The Nitnem project is a mobile application focused on delivering spiritual content (Nitnem) to users, supporting offline-first synchronization for audio and transcript content.

## Key Technologies
- **Mobile:** Flutter (Dart)
- **Backend:** Firebase (Firestore, RemoteConfig)
- **Admin Panel:** React (TypeScript)

## Documentation Structure
Refer to `docs/` for detailed architectural and functional information.

## Architectural Principles
- Offline-First: Local caching of audio and transcripts.
- Synchronization: Periodic sync with Firebase to keep content updated.
- Component-Based: Reusable Flutter widgets for design system consistency.
