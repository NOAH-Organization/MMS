---
name: mms-design-guideline
description: Apply the NOAH MMS UI/UX design system when designing or implementing any UI in this project. Use when creating components, choosing colors, typography, spacing, layout, or reviewing visual design decisions. All tokens, classes, and rules here are authoritative — do not deviate without explicit instruction.
metadata:
  version: 1.0.0
---

# NOAH MMS — UI/UX Design Guideline

All UI implementation must follow this guide exactly. Use the Tailwind utility classes and config tokens defined here. The authoritative Tailwind configuration is in **Section 13** of [docs/DESIGN_GUIDELINE.md](../../../docs/DESIGN_GUIDELINE.md).

---

## 1. Brand Identity

- **Theme:** Dark-first. Light theme is out of scope for the initial release.
- **Visual personality:** Geometric, bold, technical, dark.
- **Primary background:** `bg-surface-base` (`#0D0D0D`).

### Logo Usage Rules

- **Minimum width:** 120px (horizontal), 48px (icon-only).
- **Clear space:** `p-4` (16px) on all sides minimum.
- Do not recolor, stretch, rotate, or apply effects to the logo.
- Do not place the primary logo on any background lighter than `#2A2A2A`.
- On colored or red backgrounds, use the white/transparent variant only.

---

## 2. Color System

All colors are registered in `tailwind.config.ts`. Always use the token classes — never raw hex values in JSX.

### Brand Colors

| Token | Hex | Usage |
| --- | --- | --- |
| `brand-red` | `#D42B2B` | Primary actions, CTAs, active states |
| `brand-red-hover` | `#B82222` | Hover state for red elements |
| `brand-red-active` | `#9C1C1C` | Pressed state |
| `brand-red-muted` | `#3D1010` | Red-tinted surfaces, active nav backgrounds |
| `brand-red-subtle` | `#2A0A0A` | Very faint red tint for hover backgrounds |

### Surface (Background) Scale

| Token | Hex | Usage |
| --- | --- | --- |
| `surface-base` | `#0D0D0D` | Page background |
| `surface` | `#161616` | Cards, panels |
| `surface-elevated` | `#222222` | Modals, dropdowns, tooltips |
| `surface-overlay` | `#2C2C2C` | Input fields, hover overlays |
| `surface-subtle` | `#1A1A1A` | Alternate row backgrounds, subtle sections |

### Stroke (Border) Colors

| Token | Hex | Usage |
| --- | --- | --- |
| `stroke-subtle` | `#222222` | Barely visible dividers |
| `stroke` | `#333333` | Standard borders |
| `stroke-strong` | `#505050` | Emphasized borders |
| `stroke-brand` | `#D42B2B` | Brand-accent borders, focused inputs |

### Content (Text) Colors

| Token | Hex | Usage |
| --- | --- | --- |
| `content-primary` | `#F2F2F2` | Main body text |
| `content-secondary` | `#A3A3A3` | Supporting text, metadata |
| `content-muted` | `#666666` | Placeholders, disabled labels |
| `content-inverse` | `#0D0D0D` | Text on light or red backgrounds |
| `content-brand` | `#D42B2B` | Brand-colored text links |
| `content-brand-hover` | `#E85555` | Hover state for brand text links |

### Semantic Colors

| Token | Hex | Usage |
| --- | --- | --- |
| `success` / `success-bg` | `#22C55E` / `#0F2A1A` | Positive states |
| `warning` / `warning-bg` | `#F59E0B` / `#2A1E08` | Caution states |
| `error` / `error-bg` | `#EF4444` / `#2A0F0F` | Errors only — distinct from brand red |
| `info` / `info-bg` | `#3B82F6` / `#0D1A2A` | Informational states |

### Color Usage Rules

- `bg-brand-red` is reserved for: primary buttons, active nav items, links, progress indicators, ratings, and critical badges. Do not use it for decorative fills.
- **Never** place `text-content-brand` on `bg-brand-red`.
- Minimum contrast: **4.5:1** for body text (WCAG AA), **3:1** for large text/UI components.
- Use semantic colors only for their intended meaning — do not repurpose for branding.

---

## 3. Typography

### Font Stack

| Role | Font | Tailwind Class |
| --- | --- | --- |
| Display & Headings | Barlow Condensed | `font-display` |
| Body, UI & Labels | Inter | `font-sans` |
| Code & Admin Data | JetBrains Mono | `font-mono` |

### Type Scale

| Token | Tailwind Classes | Size | Usage |
| --- | --- | --- | --- |
| `display-2xl` | `font-display font-extrabold text-display-2xl` | 72px | Hero banners |
| `display-xl` | `font-display font-bold text-display-xl` | 56px | Page titles |
| `display-lg` | `font-display font-bold text-display-lg` | 40px | Section heroes |
| `heading-xl` | `font-display font-bold text-heading-xl` | 32px | H1 |
| `heading-lg` | `font-display font-semibold text-heading-lg` | 24px | H2 |
| `heading-md` | `font-sans font-semibold text-heading-md` | 20px | H3, panel titles |
| `heading-sm` | `font-sans font-semibold text-heading-sm` | 16px | H4, section labels |
| `body-lg` | `font-sans font-normal text-body-lg` | 16px | Primary body text |
| `body-md` | `font-sans font-normal text-body-md` | 14px | Secondary body |
| `body-sm` | `font-sans font-normal text-body-sm` | 12px | Captions, hints |
| `label-lg` | `font-sans font-medium text-label-lg` | 14px | Buttons, tags |
| `label-sm` | `font-sans font-medium text-label-sm` | 12px | Badges, chips |
| `mono` | `font-mono font-normal text-mono` | 13px | Code, data tables |

### Typography Rules

- Use `font-display` exclusively for headings and display text — never for paragraphs or labels below `heading-sm`.
- Use `font-sans` for all body copy, UI labels, form fields, buttons, navigation, and metadata.
- Use `font-mono` only for code blocks and dense admin data tables.
- Do not mix font weights arbitrarily. Stick to the defined scale.
- Font size must never go below `text-body-sm` (12px) in the UI.

---

## 4. Spacing System

Base unit: **4px**. All spacing tokens map directly to Tailwind's built-in scale.

| Token | Tailwind | Value |
| --- | --- | --- |
| `space-1` | `1` | 4px |
| `space-2` | `2` | 8px |
| `space-3` | `3` | 12px |
| `space-4` | `4` | 16px |
| `space-6` | `6` | 24px |
| `space-8` | `8` | 32px |
| `space-12` | `12` | 48px |
| `space-16` | `16` | 64px |

---

## 5. Border Radius

| Token | Tailwind Class | Value | Usage |
| --- | --- | --- | --- |
| `radius-xs` | `rounded-sm` | 2px | — |
| `radius-sm` | `rounded` | 4px | — |
| `radius-md` | `rounded-lg` | 8px | Buttons, inputs, cards |
| `radius-lg` | `rounded-xl` | 12px | Panels, sheets |
| `radius-xl` | `rounded-2xl` | 16px | Large modals |
| `radius-2xl` | `rounded-3xl` | 24px | Full-bleed hero blocks |
| `radius-full` | `rounded-full` | 9999px | Pills, avatars, toggles |

---

## 6. Elevation & Shadows

| Tailwind Class | Usage |
| --- | --- |
| `shadow-sm` | Subtle elevation |
| `shadow-md` | Cards on hover |
| `shadow-lg` | Modals, dropdowns |
| `shadow-xl` | Full-screen overlays |
| `shadow-brand` | Red glow — use sparingly on primary CTAs or featured cards only |

---

## 7. Layout & Grid

### Breakpoints

| Prefix | Width | Notes |
| --- | --- | --- |
| `xs:` | 320px | Small mobile |
| `sm:` | 480px | **Overridden** from Tailwind default (640px) |
| `md:` | 768px | Tablet |
| `lg:` | 1024px | Small desktop |
| `xl:` | 1280px | **Desktop — PRIMARY TARGET** |
| `2xl:` | 1536px | Wide desktop |
| `3xl:` | 1920px | Ultrawide |

### Desktop Layout

- **Top bar** (`h-topbar` = 64px): `sticky top-0 z-[100]`; contains logo, global search, notifications, user avatar.
- **Sidebar** (`w-sidebar` = 280px expanded / `w-sidebar-collapsed` = 64px icon-only): `transition-[width] duration-200 ease-in-out`
- **Main content:** `flex-1 overflow-y-auto p-6`
- **Max content width:** `max-w-content` (1440px), centered with `mx-auto`

### Mobile Layout

- Top bar: `h-topbar-mobile` (56px), `sticky top-0`
- Sidebar collapses to bottom navigation bar: `h-bottom-nav` (60px), max 5 items, `fixed bottom-0`
- Main content: `flex-1 overflow-y-auto p-4`

### Manga Grid

```html
<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4">
```

**Manga cover aspect ratio:** `aspect-[2/3]` — enforced always. This is the universal standard for manga/book covers.

---

## 8. Component Patterns

### Buttons

Shared classes for **all** buttons:

```
rounded-lg font-medium transition-colors duration-150
disabled:opacity-40 disabled:cursor-not-allowed
focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-red
```

| Variant | Classes |
| --- | --- |
| `primary` | `bg-brand-red text-content-inverse hover:bg-brand-red-hover active:bg-brand-red-active` |
| `secondary` | `bg-transparent text-brand-red border border-brand-red hover:bg-brand-red-subtle` |
| `ghost` | `bg-transparent text-content-primary hover:bg-surface-overlay` |
| `danger` | `bg-error text-white hover:bg-error/90` |
| `subtle` | `bg-surface-overlay text-content-primary hover:bg-surface-elevated` |

| Size | Height | Classes |
| --- | --- | --- |
| `sm` | 32px | `h-8 px-3 text-label-sm` |
| `md` | 40px | `h-10 px-4 text-label-lg` |
| `lg` | 48px | `h-12 px-6 text-label-lg` |

### Inputs & Form Fields

Base classes:

```
h-10 px-3 rounded-lg bg-surface-overlay border border-stroke text-content-primary
font-sans text-body-md placeholder:text-content-muted
transition-colors duration-150 w-full
```

States:
- **Default:** `border-stroke`
- **Focused:** `focus:border-stroke-brand focus:ring-2 focus:ring-brand-red/20 focus:outline-none`
- **Error:** `border-error ring-2 ring-error/20`
- **Disabled:** `opacity-50 cursor-not-allowed bg-surface-subtle`

Labels: `font-sans font-medium text-label-lg text-content-primary mb-1 block`

Error messages: `font-sans text-body-sm text-error mt-1`

### Manga Cards

```
bg-surface rounded-lg border border-stroke-subtle overflow-hidden
transition-all duration-150 ease-out
hover:-translate-y-0.5 hover:shadow-md hover:border-stroke-strong
```

Structure: `aspect-[2/3]` cover image → `p-3` info area with title (`font-sans font-semibold text-heading-sm line-clamp-2`) and metadata (`font-sans text-body-sm text-content-secondary mt-1`).

Status badges (`absolute top-2 left-2`, shared: `font-sans font-medium text-label-sm rounded px-1.5 py-0.5`):
- Ongoing: `bg-info text-white` · Completed: `bg-success text-white` · Hiatus: `bg-warning text-white` · Cancelled: `bg-error text-white`

### Tags / Genre Chips

```
bg-surface-elevated border border-stroke-subtle rounded-full px-2.5 py-1
font-sans font-medium text-label-sm text-content-secondary
transition-colors duration-150
hover:bg-surface-overlay hover:text-content-primary hover:border-stroke
```

Active/selected: `bg-brand-red-muted text-brand-red border-brand-red`

### Navigation (Sidebar)

Nav item base:

```
flex items-center gap-3 h-11 px-4 rounded-lg w-full
font-sans text-body-md text-content-secondary
transition-colors duration-150 cursor-pointer
hover:bg-surface-overlay hover:text-content-primary
```

Active state: `bg-brand-red-muted text-brand-red font-medium border-l-[3px] border-brand-red pl-[13px]`

Icon size: `w-5 h-5` (20px)

### Modals & Dialogs

Overlay: `fixed inset-0 bg-black/75 z-[200] flex items-center justify-center p-4`

Panel:

```
bg-surface-elevated border border-stroke rounded-2xl p-6 shadow-xl w-full
```

Sizes: `max-w-sm` (560px small) · `max-w-2xl` (720px medium) · `max-w-4xl` (960px large)

- Close button: `absolute top-4 right-4` (icon only, ghost/sm)
- Header: `font-sans font-semibold text-heading-md text-content-primary mb-4`
- Footer: `flex justify-end gap-3 mt-6`

### Admin Tables

Container: `bg-surface border border-stroke-subtle rounded-xl overflow-hidden`

Header row: `bg-surface-elevated font-sans font-semibold text-heading-sm text-content-secondary`

Data rows: `h-[52px] border-b border-stroke-subtle font-sans text-body-md text-content-primary hover:bg-surface-overlay`

Numeric/ID columns: `font-mono text-mono`

### Notifications & Toasts

Position: `fixed top-4 right-4 z-[300] flex flex-col gap-2`

Panel: `w-[360px] bg-surface-elevated border border-stroke rounded-xl p-4 shadow-lg border-l-4`

Left border by type: `border-l-success` · `border-l-warning` · `border-l-error` · `border-l-info`

- Auto-dismiss: **5 seconds**. Errors: **persistent** until manually dismissed.

---

## 9. Iconography

- **Library:** Lucide Icons — consistent stroke-based icons.
- **Default stroke width:** `1.5px`.
- **Sizes:** `w-4 h-4` (16px inline) · `w-5 h-5` (20px UI standard) · `w-6 h-6` (24px navigation) · `w-8 h-8` (32px feature)
- Icons must always be paired with a text label or `aria-label`.
- Do not mix icon styles (filled vs. outline) within the same context.

---

## 10. Reading View

- **Background:** `bg-black` (`#000000`) — maximizes contrast for manga pages.
- **UI chrome:** Minimal. Control bars: `opacity-0 hover:opacity-100 focus-within:opacity-100 transition-opacity duration-300`; auto-hide after 3 seconds of inactivity.
- **Control bar:** `h-14 bg-black/85 backdrop-blur-sm flex items-center px-4`
- No sidebar in reading view. Exit button returns to the manga's detail page.

---

## 11. Interaction & Motion

| Property | Value |
| --- | --- |
| Default transition | `transition-colors duration-150 ease-out` |
| Transform transition | `transition-all duration-150 ease-out` |
| Emphasized transition | `transition-all duration-[250ms] ease-out` |
| Page enter | `animate-fade-in` (opacity 0→1, 200ms) |
| Modal enter | Slide up + fade in |
| Modal exit | Fade only |

Always add `motion-reduce:transition-none motion-reduce:transform-none` to all animated elements.

---

## 12. Accessibility

- Minimum contrast: **4.5:1** for body text, **3:1** for large text and UI components.
- All interactive elements must have a visible focus ring: `focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-red`
- All `<img>` must have `alt`; decorative images use `alt=""`.
- ARIA roles and labels are required on all custom interactive components (menus, modals, tabs, sliders).
- Never convey information through color alone — pair with icons or text labels.
