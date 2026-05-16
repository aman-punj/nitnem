# Admin Panel

Path: `admin_panel/`

## Stack
- React + Vite + TypeScript
- Firestore metadata writes
- Transcript parse/timing utilities

## Structure
Sidebar sections:
- Dashboard
- Content
- Categories
- Feedback
- Live Content
- App Config
- Storage
- Settings

Current migration state:
- Content section is fully active (search, edit, drag/drop ordering, pinning).
- Other sections are scaffolded for phased implementation.

## Content Management
- Drag-and-drop ordering persists `displayOrder`.
- Pin-to-top is supported.
- `categoryId` is now editable per content item.

## Transcript Support
- Timed LRC parses into timed segments.
- Plain lines parse into untimed segments.
- Unified transcript output supports both synced and plain/focus reading modes.

## Feedback (Planned Next)
- Cursor-based Firestore pagination.
- Status tags: `open`, `resolved`, `ignored`.
