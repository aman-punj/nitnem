# Design System Audit

## Overview
The mobile app utilizes a centralized, token-based design system named **"Sacred Radiance"**. This system aims to provide a premium, spiritual aesthetic with carefully curated colors, typography, and spacing.

## Architecture
- **Location:** `mobile_app/lib/core/design_system/`
- **Structure:**
  - `/models`: Contains `AppTokens` representing the raw design variables (colors, spacing, typography, radii).
  - `/tokens`: Hardcoded token implementations (e.g., `sacred_tokens.dart`).
  - `/theme`: Logic to map `AppTokens` to standard Flutter `ThemeData` (`sacred_dark_theme.dart`). Uses custom `ThemeExtensions` (`SacredPalette`).
  - `/widgets`: Reusable customized UI components (`sacred_app_bar.dart`, `sacred_loader.dart`, `sacred_segmented_control.dart`, `focus_transcript_line.dart`).

## Key Characteristics
- **Typography:** Relies heavily on high-end Google Fonts like `Playfair Display` for headings and `Inter` for body/metadata.
- **Color Palette:** Dominated by a "Sacred Dark Theme", utilizing a deep gold primary accent alongside very dark container backgrounds to give a "glassmorphic" and rich aesthetic.
- **Components:** Built with a focus on immersive experiences (e.g., the glassmorphic player at the bottom of the prayer screen, subtle glow and shadow effects).

## Identified Issues & Areas for Improvement
- **Token Completeness:** While many tokens exist, there are still some hardcoded values in UI elements (e.g., padding inside specific pages, or blur sigmas in `prayer_page.dart`) that could be tokenized.
- **Theme Coupling:** The `ThemeData` creation in `sacred_dark_theme.dart` is massive. It handles almost all material widget overrides. As the app grows, this single file will become harder to maintain.
- **Missing Light Theme:** Currently, the system seems predominantly geared towards dark mode. Implementing a "Sacred Light" theme may require significant auditing of contrast ratios and token mappings.
- **Consistency:** Ensuring that all new screens strictly import from `/design_system/widgets` rather than using standard Flutter `Material` widgets directly.
