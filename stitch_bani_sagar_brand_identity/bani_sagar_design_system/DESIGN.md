---
name: Bani Sagar Design System
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1b1b1b'
  surface-container: '#1f1f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#303030'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#b7c7e8'
  on-secondary: '#21314b'
  secondary-container: '#384763'
  on-secondary-container: '#a6b5d6'
  tertiary: '#d0cecb'
  on-tertiary: '#30312e'
  tertiary-container: '#b4b3af'
  on-tertiary-container: '#454543'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#d6e3ff'
  secondary-fixed-dim: '#b7c7e8'
  on-secondary-fixed: '#0a1b35'
  on-secondary-fixed-variant: '#384763'
  tertiary-fixed: '#e4e2de'
  tertiary-fixed-dim: '#c8c6c3'
  on-tertiary-fixed: '#1b1c1a'
  on-tertiary-fixed-variant: '#474744'
  background: '#131313'
  on-background: '#e2e2e2'
  surface-variant: '#353535'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.7'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.4'
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
  xl: 80px
  container-max: 1200px
  gutter: 24px
---

## Brand & Style

The design system is rooted in **Spiritual Minimalism**, a philosophy that treats the user interface as a digital sanctuary. It prioritizes mental clarity through generous whitespace and a reduction of visual noise, allowing the content—the sacred text and meditative guidance—to breathe.

The aesthetic blends the classical elegance of traditional scripture with the sleek functionalism of modern wellness applications. It utilizes soft glows and subtle gradients to suggest a sense of enlightenment and divine presence. The interface should feel expensive yet humble, achieved through high-quality typography and a disciplined use of gold accents.

## Colors

This design system employs an adaptive palette that shifts between the infinite depth of an AMOLED night and the warmth of physical parchment.

- **Dark Mode (Default):** Uses a true black base to save energy and reduce eye strain during nighttime reflection. Deep navy is used for container backgrounds to provide subtle depth without breaking the "infinite" feel. Champagne Gold is the "light-bringer," used sparingly for focus points.
- **Light Mode:** Replaces clinical whites with Warm Ivory and Pearl, creating a "bibliotheca" feel. The gold is slightly muted to maintain legibility against the lighter backdrop, and charcoal replaces pure black for a softer reading experience.
- **Accents:** Gold is never used for large surfaces; it is reserved for icons, thin borders, and active states to signify "sacred" status.

## Typography

Typography is the cornerstone of this design system. We pair the high-contrast, editorial serif **Playfair Display** with the utilitarian precision of **Inter**.

- **Playfair Display:** Used for titles, section headers, and pulled quotes. It evokes the feeling of a printed manuscript.
- **Inter:** Used for all functional UI elements, navigation, and long-form body text. The generous line-height (1.6 to 1.7) in body copy is critical for a relaxed, meditative reading pace.
- **Styling:** Use `label-md` for small headers above titles (all caps with tracking) to provide a structural hierarchy without competing with the headlines.

## Layout & Spacing

The layout philosophy follows a **Fixed-Fluid Hybrid** model. For mobile, a 4-column grid with 20px margins is used. For desktop, a 12-column grid capped at 1200px ensures content remains readable and focused.

- **Generous Whitespace:** We use "negative space" as a functional element. Screens should never feel crowded. The `xl` (80px) spacing is frequently used between major content sections to allow the user's mind to rest.
- **Centric Alignment:** For core spiritual content (verses or prayers), use centered layouts to emphasize balance and focus.
- **Rhythm:** All margins and paddings must be multiples of 8px to maintain a mathematical harmony across the UI.

## Elevation & Depth

This design system avoids traditional heavy shadows, opting instead for **Tonal Layers** and **Luminous Halos**.

- **Tonal Layers:** In Dark Mode, depth is created by moving from `#000000` (Background) to `#081221` (Surface). In Light Mode, we move from `#fdfbf7` to `#ffffff`.
- **Soft Glows:** Rather than a black shadow, active elements or "sacred" cards may feature a very faint gold outer glow (e.g., `box-shadow: 0 0 20px rgba(212, 175, 55, 0.15)`).
- **Glassmorphism:** Navigation bars and player controls should use a high-blur backdrop filter (30px+) with 80% opacity to maintain a sense of lightness and transparency.

## Shapes

The shape language is **Rounded**, reflecting the softness and fluidity of water and breath.

- **Standard Elements:** Buttons, input fields, and small cards use a 0.5rem (8px) radius.
- **Feature Cards:** Large containers or "Daily Bani" cards should use the `rounded-xl` (1.5rem / 24px) setting to appear approachable and soft.
- **Icons:** Use "Linear" or "Light" weight icons with rounded caps. Avoid sharp, jagged edges in any custom iconography.

## Components

- **Buttons:** Primary buttons are solid Champagne Gold with Ivory text (Dark Mode) or Charcoal text (Light Mode). Secondary buttons are ghost-style with a 1px Gold border.
- **Cards:** Use very thin, low-opacity borders (1px Gold at 10% opacity) instead of shadows to define card boundaries.
- **Inputs:** Minimalist bottom-border only or very softly rounded containers. Focus state is indicated by a subtle gold glow.
- **Progress Bars (Meditation/Audio):** Thin 2px lines. The "filled" portion should have a small "glow" head to represent the current moment.
- **Lists:** High-density lists are avoided. Each list item should have at least 16px of vertical padding to ensure a premium, unhurried feel.
- **Audio Player:** A bespoke component featuring a large play/pause button centered, using glassmorphism for the background to let the album/scripture art bleed through.