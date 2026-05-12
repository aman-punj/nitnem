---
name: Sacred Radiance
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#f0c12c'
  on-secondary: '#3d2e00'
  secondary-container: '#d2a501'
  on-secondary-container: '#503d00'
  tertiary: '#cfcfc1'
  on-tertiary: '#2f3128'
  tertiary-container: '#b3b4a6'
  on-tertiary-container: '#44463c'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#ffdf90'
  secondary-fixed-dim: '#f0c12c'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#584400'
  tertiary-fixed: '#e3e3d5'
  tertiary-fixed-dim: '#c7c7ba'
  on-tertiary-fixed: '#1b1c14'
  on-tertiary-fixed-variant: '#46483d'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 120px
---

## Brand & Style

The brand identity centers on a "Sacred Radiance"—a design philosophy that treats the digital interface as a digital sanctuary. The goal is to evoke a sense of peace, reverence, and timelessness, suitable for the daily recitation of Nitnem. The target audience spans from devout practitioners to modern spiritual seekers who value both cultural heritage and high-end digital craftsmanship.

The design style is a blend of **Minimalism** and **Glassmorphism**. By using heavy whitespace (or "darkspace" in this context) and translucent layers, the UI avoids clutter and focuses the user's attention on the sacred text (Gurbani). The atmosphere is defined by a "meditative glow," where light feels as though it is emitting from the text itself rather than a backlight. Every interaction should feel intentional, smooth, and quiet, avoiding any jarring transitions or loud, generic aesthetics.

## Colors

The palette is rooted in the "AMOLED-friendly" darkness of the night, providing a perfect canvas for the "divine warmth" of gold and saffron.

- **Primary Gold (#D4AF37):** Used for key iconography, primary headings, and active states. It represents the "Eternal Light."
- **Deep Saffron (#F4C430):** An accent color used sparingly for emphasis, call-to-actions, or ritualistic highlights (e.g., progress indicators for prayers).
- **Subtle Ivory (#FFFFF0):** This is the primary color for body text. It is softer on the eyes than pure white, maintaining a parchment-like elegance.
- **Deepest Black (#0A0A0A):** The base background layer, ensuring maximum contrast and battery efficiency on OLED screens.
- **Surface Gray (#121212):** Used for elevated cards and containers to create subtle depth without breaking the dark immersion.

## Typography

This design system uses a high-contrast typographic pairing to balance tradition with readability. 

- **Headings:** **Playfair Display** provides a timeless, editorial feel. It should be used for titles of Banis (prayers), section headers, and significant navigational points.
- **Body & Gurbani:** **Inter** is selected for its exceptional legibility at various scales. While Gurbani text may use specific Gurmukhi fonts, the surrounding translations and transliterations must remain clean and functional.
- **Hierarchy:** Display sizes use tighter letter-spacing to feel "premium," while labels use increased letter-spacing and uppercase styling to denote metadata or secondary information.

## Layout & Spacing

The layout philosophy is built on **Generous Breathing Room**. To facilitate a meditative state, the UI must never feel cramped.

- **Grid:** A 12-column fluid grid for desktop and a 4-column grid for mobile.
- **Rhythm:** An 8px linear scale governs all padding and margins. 
- **Reading Mode:** For the primary reading experience (the Nitnem player), a fixed-width central column (max 720px) is utilized to ensure optimal line length and focus, regardless of screen size.
- **Adaptation:** On mobile, margins are reduced to 20px to maximize the reading area, while desktop layouts use wide 120px margins to create an "altar-like" centered focus.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Subtle Glows** rather than harsh shadows.

- **Surface Tiers:** The base layer is #0A0A0A. Secondary containers (cards, menus) use #121212. 
- **Glassmorphism:** Overlays, such as bottom sheets or navigation bars, use a semi-transparent blur (20px-30px) to maintain a sense of context.
- **Glow Effects:** Instead of traditional drop shadows, active elements or "now reading" states utilize a soft, golden outer glow (`rgba(212, 175, 55, 0.15)`). This creates the "sacred ambience" requested, making elements appear to radiate light.
- **Dividers:** Use low-opacity golden gradients for horizontal rules, fading out at the edges to avoid "boxing in" the content.

## Shapes

The shape language is **Soft and Elegant**. 

- **Primary Elements:** Buttons and cards use a 0.5rem (8px) radius, providing a modern but grounded feel.
- **Decorative Elements:** Use circular or organic shapes for profile avatars or decorative frames.
- **Enclosures:** "Pill" shapes are reserved exclusively for status indicators (e.g., "Completed") or chips to differentiate them from functional buttons.

## Components

- **Buttons:** Primary buttons feature a solid #D4AF37 background with #0A0A0A text. Secondary buttons are "ghost" style with a 1px #D4AF37 border.
- **Cards:** Used for Bani selections. They feature a #121212 background with a very subtle 0.5px border in Ivory (#FFFFF0) at 10% opacity.
- **The Reading Interface:** The "Nitnem Player" includes a progress bar that uses a saffron-to-gold gradient. Text size toggles and translation switches should be tucked into a bottom sheet to keep the main view sacred.
- **Input Fields:** Minimalist design with only a bottom-border that glows golden when focused.
- **Selection Controls:** Radio buttons and checkboxes use a custom "lotus" or geometric "circle-in-circle" design in Gold to reinforce the spiritual theme.
- **Audio Bar:** A persistent, translucent blurred bar at the bottom for Banis that have audio accompaniment, featuring a subtle waveform visualization in Saffron.