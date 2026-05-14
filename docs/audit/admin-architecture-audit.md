# Admin Architecture Audit

## Overview
The Admin panel is a single-page React application built using Vite. It is hosted via Firebase Hosting. The app provides a user interface for managing app configurations and content (prayers and YouTube live streams) in Firestore.

## Core Stack
- **Framework:** React + Vite
- **Language:** TypeScript
- **State Management:** React hooks (`useState`, `useEffect`, `useMemo`)
- **Drag and Drop:** `@dnd-kit/core` and `@dnd-kit/sortable`
- **Backend/Database:** Firebase Firestore

## Project Structure (`admin_panel/src/`)
- `/components`: UI components like `TimingTool.tsx`, `admin/PrayerCard.tsx`, `admin/ContentEditor.tsx`, `admin/RemoteConfigEditor.tsx`.
- `/pages`: Main application page `AdminApp.tsx`.
- `/lib`: Services and types for interacting with Firebase (`contentService.ts`, `remoteConfigService.ts`, `transcript.ts`).
- `main.tsx`: App entry point.

## Key Flows
- **Dashboard (`AdminApp.tsx`):** Consists of a sidebar to switch between "App Config" and "Content Management".
- **App Config:** Allows updating global settings and app update messages (minor/force updates, maintenance mode). Driven by `RemoteConfigEditor`.
- **Content Management:** Allows creating, updating, and reordering content items. Implements drag-and-drop reordering with `@dnd-kit`. Reordering updates the `displayOrder` in Firestore.
- **Timing Tool:** A tool (`TimingTool.tsx`) for manually creating/syncing timestamps to transcripts via keyboard shortcuts (Space, Enter, Backspace, Arrow keys, 'f' for flag).

## Technical Debt & Observations
- **Component Complexity:** `AdminApp.tsx` is large and manages a lot of global state (items, pinned items, search, config, etc.).
- **Missing Abstractions:** Data fetching is somewhat scattered, without a structured query management library like `react-query` or `SWR`, leading to manual loading and error state management.
- **Error Handling:** Standard try-catch blocks are used but errors are surfaced directly in the UI as basic strings.

## Summary
The admin panel is functional and handles its responsibilities well, providing essential CMS capabilities for the mobile app. To improve maintainability and scalability, adopting a data fetching library and breaking down large components is recommended.
