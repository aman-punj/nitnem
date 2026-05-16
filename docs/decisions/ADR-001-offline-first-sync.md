# ADR-001: Offline-First Synchronization

## Status
Accepted

## Context
The application needs to be fully functional offline, as internet access may be limited for the target user base while performing daily prayers.

## Decision
We utilize a local-first approach using `sqflite` (or file-based storage as currently implemented) to persist content. The `SyncEngine` handles background synchronization with Firebase to keep content updated.

## Consequences
- Requires robust local file management.
- Increases application complexity regarding data consistency and conflict resolution.
