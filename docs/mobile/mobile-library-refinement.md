# mobile-library-refinement.md

You are refining the MOBILE library/home screen for Bani Sagar.

IMPORTANT:
Do NOT redesign the entire screen.
The current direction is already visually strong.

The goal is:

* improve hierarchy
* improve categorization
* improve readability
* improve data presentation
* preserve immersive premium atmosphere

---

## CURRENT ISSUES

1. “Sacred Library” heading feels AI-generated and unnecessary
2. Category grouping is missing
3. Punjabi subtitle repeats unnecessarily
4. Listing hierarchy needs refinement
5. Dynamic content structure needs cleaner rendering

---

## REMOVE

Remove:

* “Sacred Library”
* decorative marketing-style headings
* duplicated Punjabi subtitles

Avoid:

* fake spiritual marketing language

---

## TITLE STRUCTURE

Correct prayer structure:

ਜਪੁਜੀ ਸਾਹਿਬ
Japji Sahib

NOT:

ਜਪੁਜੀ ਸਾਹਿਬ
ਜਪੁਜੀ ਸਾਹਿਬ

English subtitle should:

* support readability
* improve accessibility
* preserve elegance

---

## CATEGORY GROUPING

Content MUST render grouped by categories.

Examples:

* Nitnem
* Daily Banis
* Evening Banis
* Other Banis
* Live

Requirements:

* elegant category headers
* subtle spacing rhythm
* clean grouped sections

Avoid:

* giant category cards
* excessive separators

---

## SEARCH BAR

Current search direction is GOOD.

Preserve:

* minimal styling
* layered surface
* restrained glow
* premium spacing

Do NOT redesign aggressively.

---

## LIST ITEM STRUCTURE

Prayer cards should feel:

* lightweight
* immersive
* premium
* readable

Preserve:

* current dark layered surfaces
* restrained borders
* soft glow rhythm

Improve:

* spacing consistency
* title alignment
* metadata hierarchy

---

## ICON SYSTEM

Current icons should remain as FALLBACK icons.

Frontend should use:

* local icon mapping fallback system

Example:
categoryId -> local icon

Do NOT require remote icon loading for V1.

Remote icon system may come later.

---

## DYNAMIC CONTENT REQUIREMENTS

The screen is fully backend-driven.

Backend controls:

* ordering
* visibility
* category assignment
* metadata

Frontend controls:

* rendering
* interaction
* navigation
* icon mapping

Do NOT:

* hardcode prayer lists
* hardcode categories

---

## OFFLINE-FIRST REQUIREMENTS

Config and listings should:

* fetch during splash/init
* cache locally
* use last successful cached version offline

If offline:

* silently use cached data
* avoid disruptive error states

---

## DESIGN DIRECTION

Preserve:

* AMOLED-first dark surfaces
* restrained gold accents
* calm spacing
* immersive atmosphere

Avoid:

* excessive gradients
* decorative spirituality
* cluttered layouts
* giant cards

---

## MOST IMPORTANT GOAL

The library should feel:

* calm
* organized
* immersive
* premium
* spiritually focused

NOT:

* like a generic media app
* like a marketplace
* like a decorative concept UI
