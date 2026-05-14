# ai-workflow-rules.md

# Bani Sagar — AI Workflow Rules

## Purpose

These rules define how AI agents should work within the Bani Sagar project.

The goal is:

* safe iteration
* scoped changes
* architectural consistency
* low regression risk
* maintainable evolution

This project prioritizes:

* calm UX
* immersive reading
* scalable architecture
* offline-first reliability
* restrained premium design

AI agents must preserve these principles.

---

# General Workflow Rules

## Work In Small Scoped Changes

DO:

* work on isolated features
* update only relevant files
* preserve surrounding systems
* keep changes incremental

DO NOT:

* rewrite entire modules unnecessarily
* refactor unrelated systems
* modify multiple architectures at once
* perform broad cleanup automatically

---

# Preserve Existing Architecture

Before adding new systems:

* inspect existing architecture
* reuse current patterns first
* extend instead of replacing

Avoid:

* duplicate pipelines
* parallel architectures
* temporary hacks
* unnecessary abstractions

---

# UI Development Rules

The application follows:

* AMOLED-first design
* sacred minimalism
* immersive reading philosophy
* restrained gold accent system
* atmospheric layering

DO:

* preserve spacing rhythm
* preserve typography hierarchy
* use semantic colors
* keep interfaces calm and uncluttered

DO NOT:

* introduce flashy UI
* overuse gradients
* create neon/glass overload
* add decorative religious visuals
* make karaoke-style transcript UI

---

# Mobile First Priority

Current development priority:

* mobile portrait experience

Tablet/web optimization:

* secondary priority
* should not complicate mobile UX

Avoid:

* premature responsive complexity
* overengineering layouts

---

# Offline First Rules

The app is offline-first.

DO:

* cache remote config
* cache content safely
* preserve local fallback behavior

DO NOT:

* assume network availability
* block app startup unnecessarily
* tightly couple UI to live backend state

---

# Backend Responsibility Rules

Backend controls:

* visibility
* ordering
* metadata
* feature flags
* remote configuration

Frontend controls:

* rendering logic
* navigation
* feature execution
* interaction behavior

DO NOT:

* move application logic into Firestore
* create backend-driven UI trees
* create dynamic executable logic from backend

---

# Firestore Rules

Keep Firestore:

* simple
* scalable
* predictable

Prefer:

* flat readable structures
* stable document paths
* additive schema evolution

Avoid:

* deeply nested structures
* unstable naming
* inconsistent field conventions

Use:

* build numbers for version checks
  NOT semantic version comparisons.

---

# Feature Development Rules

Before introducing new features:

* verify if current systems already support it
* preserve unified architectures
* avoid feature fragmentation

Current priority:

* polish
* consistency
* UX refinement
* operational stability

NOT:

* endless new systems

---

# Design Consistency Rules

All UI must align with:

* existing design system
* existing typography scale
* existing spacing system
* existing glow/elevation philosophy

If uncertain:
prefer restraint over decoration.

---

# Performance Rules

Prioritize:

* smooth scrolling
* lightweight rendering
* stable animations
* low rebuild frequency

Avoid:

* excessive blur
* rebuild-heavy opacity systems
* deeply nested animations
* expensive layout recalculations

---

# AI Modification Rules

When making changes:

* explain important architectural decisions
* preserve backward compatibility where possible
* avoid destructive operations
* prefer additive implementations

Always assume:
existing systems may already be in use elsewhere.

---

# Most Important Principle

Bani Sagar should feel:

* calm
* immersive
* spiritually focused
* premium through restraint

NOT:

* feature overloaded
* visually noisy
* enterprise-like
* gamified
