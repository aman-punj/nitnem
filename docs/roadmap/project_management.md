Audit, organize, and restructure the Nitnem project documentation and architecture files into a clean, scalable, production-grade developer documentation system.

Current Situation:
The project contains:

* architecture markdown files
* AI audit reports
* technical debt reports
* feature planning docs
* settings/design system notes
* backend/frontend structure notes
* sync/offline-first architecture notes
* admin panel notes
* implementation prompts
* scattered planning documents

Goal:
Transform the current documentation into a structured engineering knowledge system that is:

* maintainable
* discoverable
* scalable
* developer-friendly
* AI-friendly
* future-proof

IMPORTANT:
Do NOT rewrite everything unnecessarily.
Focus on:

* organizing
* deduplicating
* categorizing
* improving structure
* identifying outdated/conflicting docs
* improving clarity

---

## PRIMARY OBJECTIVES

1. Organize documentation into logical folders
2. Remove duplicated concepts
3. Identify outdated or conflicting docs
4. Improve naming consistency
5. Create proper architecture hierarchy
6. Improve readability
7. Make docs AI-agent friendly
8. Separate implementation docs from planning docs
9. Create clear ownership boundaries
10. Reduce chaos and context fragmentation

---

## TARGET DOCUMENTATION STRUCTURE

Organize docs into something similar to:

docs/
architecture/
frontend/
backend/
mobile/
admin_panel/
design_system/
features/
audits/
workflows/
prompts/
decisions/
setup/
roadmap/

Adjust structure intelligently based on existing files.

---

## ARCHITECTURE DOCUMENTATION

Audit and organize:

* system architecture
* mobile architecture
* backend architecture
* offline-first sync design
* settings architecture
* audio architecture
* notification architecture

Requirements:

* remove duplicated explanations
* merge related concepts
* identify outdated architecture decisions
* improve clarity
* maintain practical scale

---

## AUDIT REPORTS

Organize audit files:

* technical debt
* UI audit
* architecture audit
* performance audit

Requirements:

* identify recurring issues
* create prioritized improvement categories
* separate:

  * critical issues
  * medium issues
  * future improvements

Avoid repeating same issue across multiple files.

---

## DESIGN SYSTEM DOCS

Organize:

* design token plans
* reusable components
* UI consistency rules
* typography guidelines
* spacing system
* app theme architecture

Requirements:

* centralize design language documentation
* remove duplicated component discussions

---

## SETTINGS + CONFIG SYSTEM

Organize docs related to:

* settings architecture
* frontend-driven rendering
* Firestore enabledItems config
* notification settings
* local preferences
* settings grouping

Ensure architecture docs clearly define:

* frontend ownership
* backend responsibilities
* local persistence strategy

---

## OFFLINE-FIRST + SYNC DOCS

Organize:

* local-first architecture
* sync engine
* pending operations
* caching
* download strategy
* transcript/audio syncing

Requirements:

* remove overengineering
* maintain practical implementation focus
* clearly separate:

  * current implementation
  * future scaling ideas

---

## CREATE ADR SECTION

Create:
docs/decisions/

Generate Architecture Decision Records (ADR).

Examples:

* why GetX was chosen
* why frontend owns settings rendering
* why offline-first approach
* why sqflite chosen
* why spiritual dark UI direction
* why audio controls remain contextual

Format:
ADR-001-title.md

Requirements:

* concise
* practical
* decision focused

---

## AI-FRIENDLY DOCUMENTATION

Optimize docs so AI agents/tools can understand project context easily.

Requirements:

* consistent naming
* avoid vague terminology
* define ownership boundaries
* reduce duplicated explanations
* improve file discoverability

Create:

* project-context.md
* terminology.md
* architecture-overview.md

---

## REMOVE DOCUMENTATION CHAOS

Identify:

* duplicate prompts
* repeated architecture ideas
* abandoned concepts
* conflicting implementation approaches
* stale TODOs

Mark:

* deprecated docs
* archived ideas
* future ideas

---

## CREATE ROADMAP

Generate:

* current priorities
* short-term roadmap
* medium-term roadmap
* future architecture goals

Separate:

* actual priorities
  vs
* nice-to-have ideas

---

## IMPORTANT RULES

Avoid:

* enterprise overengineering
* fake scalability planning
* unnecessary microservice thinking
* excessive abstraction docs
* architecture theater

Maintain:

* practical engineering focus
* current app scale awareness
* implementation realism

---

## END GOAL

The documentation system should feel:

* cohesive
* intentional
* scalable
* professional
* maintainable
* understandable by both humans and AI agents

The project should no longer feel like scattered markdown files, but instead like a structured evolving product engineering system.
