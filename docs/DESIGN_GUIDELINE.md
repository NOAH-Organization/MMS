# NOAH Manga Management System (NOAH MMS) — UI/UX Design Guideline

> **For Claude Code agents:** This file is the authoritative design reference. All UI implementation must use the Tailwind utility classes and config tokens defined here. Do not deviate from color, typography, or spacing tokens without explicit instruction. The canonical Tailwind configuration is in **Section 13**.

---

## 1. Brand Identity

### 1.1 Brand Overview

- **Product name:** NOAH MMS (Manga Management System)
- **Brand acronym meaning:** Neutralize, Organize, Analyze, Harmonize
- **Visual personality:** Geometric, bold, technical, dark — a platform built for serious readers and curators.
- **Primary theme:** Dark (default). Light theme is not required in the initial release.

### 1.2 Logo Assets

All logo files are located at `E:\SCP TV\NOAH logo\`. The following variants are available:

| File | Usage |
| --- | --- |
| `noah-red-high-resolution-logo-transparent.png` | **Primary logo** — use on dark backgrounds |
| `noah-high-resolution-logo-transparent.png` | Reversed/grayscale — use on light surfaces |
| `noah-high-resolution-logo-vertical.png` | Vertical stacked layout — splash screens, login pages |
| `noah-logo-only-black.png` | Icon-only mark — favicons, small placements, loading indicators |
| `noah-high-resolution-logo-grayscale-transparent.png` | Grayscale variant — print, monochrome contexts |

### 1.3 Logo Usage Rules

- **Minimum width:** 120px (horizontal), 48px (icon-only).
- **Clear space:** Maintain a minimum clear zone of `p-4` (16px) on all sides.
- **Do not** recolor, stretch, rotate, or apply effects to the logo.
- **Do not** place the primary logo on any background lighter than `#2A2A2A`.
- On colored or red backgrounds, use the white/transparent variant only.
- The icon mark (icosahedron only) may be used independently for favicons and avatar placeholders.

---

## 2. Color System

All colors are registered in `tailwind.config.ts` and used via utility classes (`bg-*`, `text-*`, `border-*`).

### 2.1 Brand Colors

| Token | Hex | Tailwind Class Examples | Usage |
| --- | --- | --- | --- |
| `brand-red` | `#D42B2B` | `bg-brand-red` `text-brand-red` `border-brand-red` | Primary actions, CTAs, active states |
| `brand-red-hover` | `#B82222` | `hover:bg-brand-red-hover` | Hover state for red elements |
| `brand-red-active` | `#9C1C1C` | `active:bg-brand-red-active` | Pressed state |
| `brand-red-muted` | `#3D1010` | `bg-brand-red-muted` | Red-tinted surfaces, active nav backgrounds |
| `brand-red-subtle` | `#2A0A0A` | `bg-brand-red-subtle` | Very faint red tint for hover backgrounds |
| `brand-black` | `#0D0D0D` | `bg-brand-black` | Base page background |

### 2.2 Surface (Background) Scale

| Token | Hex | Tailwind Class | Usage |
| --- | --- | --- | --- |
| `surface-base` | `#0D0D0D` | `bg-surface-base` | Page background |
| `surface` | `#161616` | `bg-surface` | Cards, panels |
| `surface-elevated` | `#222222` | `bg-surface-elevated` | Modals, dropdowns, tooltips |
| `surface-overlay` | `#2C2C2C` | `bg-surface-overlay` | Input fields, hover overlays |
| `surface-subtle` | `#1A1A1A` | `bg-surface-subtle` | Alternate row backgrounds, subtle sections |

### 2.3 Stroke (Border) Colors

| Token | Hex | Tailwind Class | Usage |
| --- | --- | --- | --- |
| `stroke-subtle` | `#222222` | `border-stroke-subtle` | Barely visible dividers |
| `stroke` | `#333333` | `border-stroke` | Standard borders |
| `stroke-strong` | `#505050` | `border-stroke-strong` | Emphasized borders |
| `stroke-brand` | `#D42B2B` | `border-stroke-brand` | Brand-accent borders, focused inputs |

### 2.4 Content (Text) Colors

| Token | Hex | Tailwind Class | Usage |
| --- | --- | --- | --- |
| `content-primary` | `#F2F2F2` | `text-content-primary` | Main body text |
| `content-secondary` | `#A3A3A3` | `text-content-secondary` | Supporting text, metadata |
| `content-muted` | `#666666` | `text-content-muted` | Placeholders, disabled labels |
| `content-inverse` | `#0D0D0D` | `text-content-inverse` | Text on light or red backgrounds |
| `content-brand` | `#D42B2B` | `text-content-brand` | Brand-colored text links |
| `content-brand-hover` | `#E85555` | `hover:text-content-brand-hover` | Hover state for brand text links |

### 2.5 Semantic Colors

| Token | Hex | Tailwind Class | Usage |
| --- | --- | --- | --- |
| `success` | `#22C55E` | `bg-success` `text-success` | |
| `success-bg` | `#0F2A1A` | `bg-success-bg` | |
| `warning` | `#F59E0B` | `bg-warning` `text-warning` | |
| `warning-bg` | `#2A1E08` | `bg-warning-bg` | |
| `error` | `#EF4444` | `bg-error` `text-error` | Errors only — distinct from brand red |
| `error-bg` | `#2A0F0F` | `bg-error-bg` | |
| `info` | `#3B82F6` | `bg-info` `text-info` | |
| `info-bg` | `#0D1A2A` | `bg-info-bg` | |

### 2.6 Color Usage Rules

- **`bg-brand-red`** is reserved for: primary buttons, active navigation items, links, progress indicators, ratings, and critical badges. Do not use it for decorative fills.
- **Never** place `text-content-brand` on `bg-brand-red`.
- Maintain a minimum contrast ratio of **4.5:1** for body text (WCAG AA) and **3:1** for large text/UI components.
- Use semantic colors only for their intended meaning — do not repurpose `text-success` for branding.

---

## 3. Typography

### 3.1 Font Stack

| Role | Font Family | Tailwind Class | Fallback |
| --- | --- | --- | --- |
| **Display & Headings** | Barlow Condensed | `font-display` | `'Arial Narrow', sans-serif` |
| **Body, UI & Labels** | Inter | `font-sans` | `'Helvetica Neue', Arial, sans-serif` |
| **Code & Admin Data** | JetBrains Mono | `font-mono` | `'Fira Code', 'Courier New', monospace` |

**Loading (Google Fonts CDN):**

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

> All three fonts support the full Latin Extended character set, including Vietnamese diacritical marks (ắ, ề, ộ, ữ, etc.).

### 3.2 Type Scale

Each row shows the full Tailwind class combination required to apply the style.

| Token | Tailwind Classes | Size | Line Height | Letter Spacing | Usage |
| --- | --- | --- | --- | --- | --- |
| `display-2xl` | `font-display font-extrabold text-display-2xl` | 72px / 4.5rem | 1.05 | -0.02em | Hero banners |
| `display-xl` | `font-display font-bold text-display-xl` | 56px / 3.5rem | 1.1 | -0.01em | Page titles |
| `display-lg` | `font-display font-bold text-display-lg` | 40px / 2.5rem | 1.15 | 0 | Section heroes |
| `heading-xl` | `font-display font-bold text-heading-xl` | 32px / 2rem | 1.2 | 0 | H1 |
| `heading-lg` | `font-display font-semibold text-heading-lg` | 24px / 1.5rem | 1.25 | 0 | H2 |
| `heading-md` | `font-sans font-semibold text-heading-md` | 20px / 1.25rem | 1.3 | 0 | H3, panel titles |
| `heading-sm` | `font-sans font-semibold text-heading-sm` | 16px / 1rem | 1.4 | 0 | H4, section labels |
| `body-lg` | `font-sans font-normal text-body-lg` | 16px / 1rem | 1.625 | 0 | Primary body text |
| `body-md` | `font-sans font-normal text-body-md` | 14px / 0.875rem | 1.6 | 0 | Secondary body |
| `body-sm` | `font-sans font-normal text-body-sm` | 12px / 0.75rem | 1.5 | 0 | Captions, hints |
| `label-lg` | `font-sans font-medium text-label-lg` | 14px / 0.875rem | 1.25 | 0.01em | Buttons, tags |
| `label-sm` | `font-sans font-medium text-label-sm` | 12px / 0.75rem | 1.2 | 0.02em | Badges, chips |
| `mono` | `font-mono font-normal text-mono` | 13px / 0.8125rem | 1.5 | 0 | Code, data tables |

### 3.3 Typography Rules

- Use `font-display` exclusively for headings and display text. Never use it for paragraphs or labels below `heading-sm`.
- Use `font-sans` (Inter) for all body copy, UI labels, form fields, buttons, navigation, and metadata.
- Use `font-mono` only for code blocks and dense admin data tables.
- Do not mix font weights arbitrarily. Stick to the defined scale.
- Heading text on dark backgrounds: use `text-content-primary` or `text-white`.
- Decorative uppercase labels may add `tracking-widest` with `text-label-sm`.

---

## 4. Spacing System

Base unit: **4px**. Tailwind's default spacing scale uses a 4px base, so **all spacing tokens map directly to Tailwind's built-in scale** — no custom overrides needed.

| Our Token | Tailwind Scale | Value | Example Classes |
| --- | --- | --- | --- |
| `space-1` | `1` | 4px | `p-1` `m-1` `gap-1` |
| `space-2` | `2` | 8px | `p-2` `gap-2` |
| `space-3` | `3` | 12px | `px-3` `py-3` |
| `space-4` | `4` | 16px | `p-4` `gap-4` |
| `space-5` | `5` | 20px | `p-5` |
| `space-6` | `6` | 24px | `p-6` `gap-6` |
| `space-8` | `8` | 32px | `p-8` |
| `space-10` | `10` | 40px | `p-10` |
| `space-12` | `12` | 48px | `p-12` |
| `space-14` | `14` | 56px | `p-14` |
| `space-16` | `16` | 64px | `p-16` |
| `space-20` | `20` | 80px | `p-20` |
| `space-24` | `24` | 96px | `p-24` |

---

## 5. Border Radius

Tailwind's v3 built-in scale aligns with the project's radius scale. Two values are overridden in config to match exactly.

| Our Token | Tailwind Class | Value | Usage |
| --- | --- | --- | --- |
| `radius-xs` | `rounded-sm` | 2px | — (overridden in config) |
| `radius-sm` | `rounded` | 4px | — (overridden in config) |
| `radius-md` | `rounded-lg` | 8px | Buttons, inputs, cards |
| `radius-lg` | `rounded-xl` | 12px | Panels, sheets |
| `radius-xl` | `rounded-2xl` | 16px | Large modals |
| `radius-2xl` | `rounded-3xl` | 24px | Full-bleed hero blocks |
| `radius-full` | `rounded-full` | 9999px | Pills, avatars, toggles |

---

## 6. Elevation & Shadows

Shadows are overridden in config to match the dark-theme aesthetic. Use Tailwind's standard shadow classes.

| Tailwind Class | Value | Usage |
| --- | --- | --- |
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.5)` | Subtle elevation |
| `shadow-md` | `0 4px 12px rgba(0,0,0,0.6)` | Cards on hover |
| `shadow-lg` | `0 8px 24px rgba(0,0,0,0.7)` | Modals, dropdowns |
| `shadow-xl` | `0 16px 48px rgba(0,0,0,0.8)` | Full-screen overlays |
| `shadow-brand` | `0 0 16px rgba(212,43,43,0.35)` | Red glow — use sparingly |

Use `shadow-brand` only on primary CTAs or featured/active manga cards. Do not use it for general decoration.

---

## 7. Layout & Grid

### 7.1 Breakpoints

Tailwind's default `sm`, `md`, `lg`, `xl`, `2xl` are preserved where possible. `xs`, `sm`, and `3xl` are customized.

| Screen | Tailwind Prefix | Width | Notes |
| --- | --- | --- | --- |
| xs | `xs:` | 320px | Added — small mobile |
| sm | `sm:` | 480px | **Overridden** from Tailwind default (640px) |
| md | `md:` | 768px | Tablet |
| lg | `lg:` | 1024px | Small desktop |
| xl | `xl:` | 1280px | **Desktop — PRIMARY TARGET** |
| 2xl | `2xl:` | 1536px | Wide desktop |
| 3xl | `3xl:` | 1920px | Added — ultrawide |

### 7.2 Page Grid

| Breakpoint | Columns | Gutter | Page Margin |
| --- | --- | --- | --- |
| xs / sm | 4 | `gap-4` (16px) | `px-4` (16px) |
| md | 8 | `gap-4` (16px) | `px-6` (24px) |
| lg | 12 | `gap-6` (24px) | `px-8` (32px) |
| xl+ | 12 | `gap-6` (24px) | `mx-auto` (max-width centered) |

**Max content width:** `max-w-content` (1440px), centered with `mx-auto`.

### 7.3 Desktop Layout Structure

```CSS
┌─────────────────────────────────────────────────────┐
│              h-topbar (64px) — sticky top           │
├────────────┬────────────────────────────────────────┤
│            │                                        │
│  w-sidebar │           flex-1 overflow-y-auto       │
│  (280px)   │           p-6 (desktop)                │
│  or        │           p-4 (tablet/mobile)          │
│  w-sidebar-│                                        │
│  collapsed │                                        │
│  (64px)    │                                        │
└────────────┴────────────────────────────────────────┘
```

- **Top Bar** (`h-topbar` = 64px): Logo, global search, notifications, user avatar. `sticky top-0 z-[100]`
- **Sidebar** (`w-sidebar` = 280px expanded / `w-sidebar-collapsed` = 64px icon-only): `transition-[width] duration-200 ease-in-out`
- **Main Content Area:** `flex-1 overflow-y-auto p-6 xl:p-6 md:p-4`

### 7.4 Mobile Layout Structure

```CSS
┌───────────────────┐
│ h-topbar-mobile   │  (56px) sticky top-0
├───────────────────┤
│                   │
│  flex-1           │
│  overflow-y-auto  │
│  p-4              │
│                   │
├───────────────────┤
│  h-bottom-nav     │  (60px) fixed bottom-0
└───────────────────┘
```

- Sidebar collapses to a **bottom navigation bar** (`h-bottom-nav` = 60px, max 5 items) on `md` and below.
- A slide-in drawer replaces the sidebar for secondary navigation on mobile.

### 7.5 Manga Grid

Use `grid` with responsive `grid-cols-*`:

```html
<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4">
```

**Manga cover aspect ratio:** `aspect-[2/3]` — enforced via Tailwind's aspect-ratio utility. This is the universal standard for manga/book covers and must be applied consistently.

---

## 8. Component Library

### 8.1 Buttons

#### Variants

| Variant | Tailwind Classes (base) | Use Case |
| --- | --- | --- |
| `primary` | `bg-brand-red text-content-inverse hover:bg-brand-red-hover active:bg-brand-red-active` | Primary actions, CTAs |
| `secondary` | `bg-transparent text-brand-red border border-brand-red hover:bg-brand-red-subtle` | Secondary actions |
| `ghost` | `bg-transparent text-content-primary hover:bg-surface-overlay` | Tertiary actions |
| `danger` | `bg-error text-white hover:bg-error/90` | Destructive actions only |
| `subtle` | `bg-surface-overlay text-content-primary hover:bg-surface-elevated` | Neutral actions in panels |

#### Sizes

| Size | Height | Tailwind Classes |
| --- | --- | --- |
| `sm` | 32px | `h-8 px-3 text-label-sm` |
| `md` | 40px | `h-10 px-4 text-label-lg` |
| `lg` | 48px | `h-12 px-6 text-label-lg` |

**Shared classes for all buttons:**

```CSS
rounded-lg font-medium transition-colors duration-150
disabled:opacity-40 disabled:cursor-not-allowed
focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-red
```

### 8.2 Inputs & Form Fields

**Base classes:**

```CSS
h-10 px-3 rounded-lg bg-surface-overlay border border-stroke text-content-primary
font-sans text-body-md placeholder:text-content-muted
transition-colors duration-150 w-full
```

**States:**

- **Default:** `border-stroke`
- **Focused:** `focus:border-stroke-brand focus:ring-2 focus:ring-brand-red/20 focus:outline-none`
- **Error:** `border-error ring-2 ring-error/20`
- **Disabled:** `opacity-50 cursor-not-allowed bg-surface-subtle`

Labels: `font-sans font-medium text-label-lg text-content-primary mb-1 block`

Error messages: `font-sans text-body-sm text-error mt-1`

### 8.3 Manga Cards

**Container:**

```CSS
bg-surface rounded-lg border border-stroke-subtle overflow-hidden
transition-all duration-150 ease-out
hover:-translate-y-0.5 hover:shadow-md hover:border-stroke-strong
```

**Structure:**

```CSS
┌───────────────────┐
│                   │
│   aspect-[2/3]    │  ← Cover: w-full object-cover
│   relative        │
│  [Status Badge]   │  ← absolute top-2 left-2
│  [Rating overlay] │  ← absolute bottom-2 left-2, opacity-0 group-hover:opacity-100
├───────────────────┤
│ p-3               │
│ Title             │  ← font-sans font-semibold text-heading-sm line-clamp-2
│ Author · Genre    │  ← font-sans text-body-sm text-content-secondary mt-1
└───────────────────┘
```

**Status badges** (`absolute top-2 left-2`):

- Ongoing: `bg-info text-white`
- Completed: `bg-success text-white`
- Hiatus: `bg-warning text-white`
- Cancelled: `bg-error text-white`

Badge shared classes: `font-sans font-medium text-label-sm rounded px-1.5 py-0.5`

### 8.4 Tags / Genre Chips

**Default:**

```CSS
bg-surface-elevated border border-stroke-subtle rounded-full px-2.5 py-1
font-sans font-medium text-label-sm text-content-secondary
transition-colors duration-150
```

**Hover:** `hover:bg-surface-overlay hover:text-content-primary hover:border-stroke`

**Active/selected:** `bg-brand-red-muted text-brand-red border-brand-red`

### 8.5 Navigation (Sidebar)

**Container:**

```CSS
bg-surface border-r border-stroke-subtle
w-sidebar transition-[width] duration-200 ease-in-out
data-[collapsed=true]:w-sidebar-collapsed
```

**Nav item (base):**

```CSS
flex items-center gap-3 h-11 px-4 rounded-lg w-full
font-sans text-body-md text-content-secondary
transition-colors duration-150 cursor-pointer
```

**Nav item states:**

- **Hover:** `hover:bg-surface-overlay hover:text-content-primary`
- **Active:** `bg-brand-red-muted text-brand-red font-medium border-l-[3px] border-brand-red pl-[13px]`

Icon size: `w-5 h-5` (20px)

### 8.6 Top Bar

```CSS
h-topbar bg-surface border-b border-stroke-subtle
flex items-center px-6 sticky top-0 z-[100]
```

On mobile: `h-topbar-mobile px-4`

Content order (left → right): Logo · `[flex-1 search bar]` · `[notifications, user menu]`

### 8.7 Modals & Dialogs

**Overlay:** `fixed inset-0 bg-black/75 z-[200] flex items-center justify-center p-4`

**Panel:**

```CSS
bg-surface-elevated border border-stroke rounded-2xl p-6 shadow-xl w-full
max-w-sm   (560px — small)
max-w-2xl  (720px — medium)
max-w-4xl  (960px — large)
```

- Close button: `absolute top-4 right-4` (icon only, `ghost` variant, `sm` size)
- Header: `font-sans font-semibold text-heading-md text-content-primary mb-4`
- Footer actions: `flex justify-end gap-3 mt-6`

### 8.8 Tables (Admin)

**Container:** `bg-surface border border-stroke-subtle rounded-xl overflow-hidden`

**Header row:** `bg-surface-elevated font-sans font-semibold text-heading-sm text-content-secondary`

**Data rows:** `h-[52px] border-b border-stroke-subtle font-sans text-body-md text-content-primary`

**Row hover:** `hover:bg-surface-overlay`

Numeric/ID columns: `font-mono text-mono`

### 8.9 Notifications & Toasts

**Position:** `fixed top-4 right-4 z-[300] flex flex-col gap-2`

**Panel:**

```CSS
w-[360px] bg-surface-elevated border border-stroke rounded-xl p-4 shadow-lg
border-l-4
```

Left border accent uses the notification type's semantic color:

- Success: `border-l-success`
- Warning: `border-l-warning`
- Error: `border-l-error`
- Info: `border-l-info`

Auto-dismiss: **5 seconds**. Errors: **persistent** until dismissed manually.

---

## 9. Iconography

- **Icon library:** [Lucide Icons](https://lucide.dev/) — consistent stroke-based icons.
- **Default stroke width:** `1.5px` (Lucide default).
- **Sizes:** `w-4 h-4` (16px inline), `w-5 h-5` (20px UI standard), `w-6 h-6` (24px navigation), `w-8 h-8` (32px feature).
- Icons must always be accompanied by a text label or `aria-label` for accessibility.
- Do not mix icon styles (e.g., filled vs. outline) within the same context.

---

## 10. Reading View

The manga reading experience is a first-class context with its own layout rules.

- **Background:** `bg-black` (pure `#000000`) — maximizes contrast for manga pages.
- **UI chrome:** Minimal. Top and bottom control bars: `opacity-0 hover:opacity-100 focus-within:opacity-100 transition-opacity duration-300`; auto-hide after 3 seconds of inactivity.
- **Page display modes:** Single page, double-page spread, long strip (vertical scroll).
- **Page navigation:** Left/right arrow keys (desktop), swipe gestures (mobile), click zones on page edges.
- **Control bar:** `h-14 bg-black/85 backdrop-blur-sm flex items-center px-4`
- **No sidebar** in reading view. Exit button returns to the manga's detail page.

---

## 11. Interaction & Motion

| Property | Tailwind Class / Value |
| --- | --- |
| Default transition | `transition-colors duration-150 ease-out` |
| Transform transition | `transition-all duration-150 ease-out` |
| Emphasized transition | `transition-all duration-[250ms] ease-out` |
| Enter animation | `duration-200` with `cubic-bezier(0.16, 1, 0.3, 1)` (custom in config) |
| Exit animation | `duration-150 ease-in` |

- **Page transitions:** `animate-fade-in` (`opacity 0 → 1`, 200ms).
- **Modal/drawer enter:** Slide up + fade. Exit: fade only.
- Respect `prefers-reduced-motion`: add `motion-reduce:transition-none motion-reduce:transform-none` to all animated elements.

---

## 12. Accessibility

- Minimum contrast ratios: **4.5:1** for body text, **3:1** for large text and UI components.
- All interactive elements must have a visible focus ring: `focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-red`
- All `<img>` elements must have `alt` attributes; decorative images use `alt=""`.
- ARIA roles and labels must be applied to all custom interactive components (menus, modals, tabs, sliders).
- Font size must never go below `text-body-sm` (12px) in the UI.
- Avoid conveying information through color alone — pair with icons or text labels.

---

## 13. Tailwind Configuration Reference

The complete `tailwind.config.ts` for this project. All tokens above derive from this file.

```ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx,js,jsx}'],
  theme: {
    screens: {
      xs:  '320px',
      sm:  '480px',   // overrides Tailwind default (640px)
      md:  '768px',
      lg:  '1024px',
      xl:  '1280px',
      '2xl': '1536px',
      '3xl': '1920px',
    },
    extend: {
      colors: {
        brand: {
          red:        '#D42B2B',
          'red-hover':   '#B82222',
          'red-active':  '#9C1C1C',
          'red-muted':   '#3D1010',
          'red-subtle':  '#2A0A0A',
          black:      '#0D0D0D',
        },
        surface: {
          base:     '#0D0D0D',
          DEFAULT:  '#161616',
          elevated: '#222222',
          overlay:  '#2C2C2C',
          subtle:   '#1A1A1A',
        },
        stroke: {
          subtle:  '#222222',
          DEFAULT: '#333333',
          strong:  '#505050',
          brand:   '#D42B2B',
        },
        content: {
          primary:       '#F2F2F2',
          secondary:     '#A3A3A3',
          muted:         '#666666',
          inverse:       '#0D0D0D',
          brand:         '#D42B2B',
          'brand-hover': '#E85555',
        },
        success: { DEFAULT: '#22C55E', bg: '#0F2A1A' },
        warning: { DEFAULT: '#F59E0B', bg: '#2A1E08' },
        error:   { DEFAULT: '#EF4444', bg: '#2A0F0F' },
        info:    { DEFAULT: '#3B82F6', bg: '#0D1A2A' },
      },

      fontFamily: {
        display: ['Barlow Condensed', 'Arial Narrow', 'sans-serif'],
        sans:    ['Inter', 'Helvetica Neue', 'Arial', 'sans-serif'],
        mono:    ['JetBrains Mono', 'Fira Code', 'Courier New', 'monospace'],
      },

      fontSize: {
        'display-2xl': ['4.5rem',    { lineHeight: '1.05',  letterSpacing: '-0.02em' }],
        'display-xl':  ['3.5rem',    { lineHeight: '1.1',   letterSpacing: '-0.01em' }],
        'display-lg':  ['2.5rem',    { lineHeight: '1.15',  letterSpacing: '0' }],
        'heading-xl':  ['2rem',      { lineHeight: '1.2',   letterSpacing: '0' }],
        'heading-lg':  ['1.5rem',    { lineHeight: '1.25',  letterSpacing: '0' }],
        'heading-md':  ['1.25rem',   { lineHeight: '1.3',   letterSpacing: '0' }],
        'heading-sm':  ['1rem',      { lineHeight: '1.4',   letterSpacing: '0' }],
        'body-lg':     ['1rem',      { lineHeight: '1.625', letterSpacing: '0' }],
        'body-md':     ['0.875rem',  { lineHeight: '1.6',   letterSpacing: '0' }],
        'body-sm':     ['0.75rem',   { lineHeight: '1.5',   letterSpacing: '0' }],
        'label-lg':    ['0.875rem',  { lineHeight: '1.25',  letterSpacing: '0.01em' }],
        'label-sm':    ['0.75rem',   { lineHeight: '1.2',   letterSpacing: '0.02em' }],
        'mono':        ['0.8125rem', { lineHeight: '1.5',   letterSpacing: '0' }],
      },

      borderRadius: {
        sm:   '2px',   // radius-xs (overrides Tailwind default 2px — same value)
        DEFAULT: '4px', // radius-sm (overrides Tailwind default 4px — same value)
      },

      boxShadow: {
        sm:    '0 1px 3px rgba(0, 0, 0, 0.5)',
        DEFAULT: '0 4px 12px rgba(0, 0, 0, 0.6)',
        md:    '0 4px 12px rgba(0, 0, 0, 0.6)',
        lg:    '0 8px 24px rgba(0, 0, 0, 0.7)',
        xl:    '0 16px 48px rgba(0, 0, 0, 0.8)',
        brand: '0 0 16px rgba(212, 43, 43, 0.35)',
      },

      width: {
        sidebar:           '280px',
        'sidebar-collapsed': '64px',
      },

      height: {
        topbar:          '64px',
        'topbar-mobile': '56px',
        'bottom-nav':    '60px',
      },

      maxWidth: {
        content: '1440px',
      },

      transitionTimingFunction: {
        enter: 'cubic-bezier(0.16, 1, 0.3, 1)',
      },

      keyframes: {
        'fade-in': {
          from: { opacity: '0' },
          to:   { opacity: '1' },
        },
      },

      animation: {
        'fade-in': 'fade-in 200ms ease-out forwards',
      },
    },
  },
  plugins: [],
}

export default config
```
