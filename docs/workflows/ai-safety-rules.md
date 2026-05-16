# ai-safety-rules.md

# Bani Sagar — AI Safety Rules

## Purpose

These rules prevent destructive or unsafe modifications to the project.

AI agents MUST follow these rules strictly.

---

# NEVER MODIFY WITHOUT EXPLICIT PERMISSION

NEVER:

* delete `.env` files
* modify secrets
* overwrite Firebase configuration
* change signing configs
* remove assets
* remove fonts
* delete project folders
* rename core directories
* remove dependencies automatically
* modify CI/CD workflows
* modify deployment credentials
* overwrite local storage schemas destructively

---

# NEVER RUN DESTRUCTIVE OPERATIONS

DO NOT:

* delete files automatically
* clean "unused" assets automatically
* remove folders automatically
* perform mass renaming
* auto migrate schemas destructively
* overwrite local cached data blindly

Always ask first before:

* deleting
* renaming
* replacing
* restructuring

---

# GIT SAFETY RULES

NEVER:

* auto commit
* auto push
* auto force push
* rewrite git history
* create destructive rebases

DO NOT:

* assume git operations are allowed
* commit generated files automatically

All git operations require explicit user approval.

---

# ENVIRONMENT SAFETY

NEVER:

* expose API keys
* expose Firebase credentials
* expose secrets in logs
* hardcode secrets into source files

DO NOT:

* move secrets into frontend code
* commit environment files
* replace environment variables automatically

---

# FIREBASE SAFETY RULES

DO NOT:

* modify Firestore rules without approval
* delete collections
* rename production collections
* migrate live schema destructively
* overwrite remote config blindly

Prefer:

* additive schema updates
* backward compatibility
* versioned migrations

---

# ASSET SAFETY RULES

DO NOT:

* remove branding assets
* replace typography assets
* overwrite exported design assets
* rename icon systems without approval

If new assets are needed:

* clearly specify required formats
* preserve current structure

Preferred:

* SVG for icons
* WebP/PNG only when necessary

---

# UI SAFETY RULES

DO NOT:

* redesign unrelated screens
* replace established design systems
* introduce inconsistent UI paradigms
* create random experimental styles

Preserve:

* AMOLED-first direction
* sacred minimalism
* restrained gold usage
* immersive reading philosophy

---

# ARCHITECTURE SAFETY RULES

DO NOT:

* introduce duplicate architectures
* create parallel state systems
* replace repositories without reason
* fragment transcript systems
* overengineer V1

Prefer:

* extending existing systems
* minimal safe improvements
* scoped changes

---

# OFFLINE-FIRST SAFETY

The application is offline-first.

NEVER:

* break cached fallback behavior
* assume constant internet access
* block app startup on remote failures

Always:

* preserve local fallback behavior
* handle offline states gracefully

---

# AI CHANGE MANAGEMENT RULES

Before major changes:

* inspect related docs
* inspect existing implementations
* preserve compatibility where possible

When uncertain:

* choose safer additive changes
* avoid destructive refactors

---

# MOST IMPORTANT RULE

Protect:

* project stability
* architecture consistency
* existing assets
* user data
* developer configuration
* offline reliability

Safety and stability are more important than aggressive optimization or refactoring.
