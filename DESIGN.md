---
version: alpha
name: Pngumpul
description: "Sistem pengumpulan tugas dan evaluasi akademik khusus guru, berorientasi pada kecepatan memeriksa kiriman, kejelasan aliran tugas, dan antarmuka minimalis modern."

colors:
  primary: "#B284BE"       # African Violet
  primary-hover: "#9f6ea9"
  accent: "#BBA3D9"        # Light Pastel Purple
  accent-light: "#EDDAF2"  # Pale Purple
  on-primary: "#0f0d13"
  background: "#0f0d13"
  surface: "#16131c"
  card: "#1c1824"
  border: "#272232"
  text: "#f5f2f8"
  text-muted: "#9f96aa"
  success: "#81c995"
  warning: "#f4c66a"
  danger: "#ff8a80"

typography:
  display:
    fontFamily: "Google Sans, Roboto, Arial, sans-serif"
    fontSize: 56px
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: -0.03em
  heading:
    fontFamily: "Google Sans, Roboto, Arial, sans-serif"
    fontSize: 32px
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: -0.02em
  body:
    fontFamily: "Roboto, Arial, sans-serif"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.65
    letterSpacing: -0.01em
  mono:
    fontFamily: "Roboto Mono, ui-monospace, SFMono-Regular, Consolas, monospace"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.6

spacing:
  base: 8px
  scale: [4, 8, 12, 16, 24, 32, 48, 64, 96, 128]

radius:
  sm: 4px
  md: 8px
  lg: 12px
  xl: 20px
  pill: 9999px

shadows:
  card: "0 1px 3px rgba(0, 0, 0, 0.22)"
  elevated: "0 8px 24px rgba(0, 0, 0, 0.32)"
  focus: "0 0 0 2px #101512, 0 0 0 4px #a8d5b5"

motion:
  duration-fast: 120ms
  duration-base: 200ms
  duration-slow: 320ms
  easing: "cubic-bezier(0.2, 0, 0, 1)"
---

## Rationale

Google Classroom supports ongoing work between students and educators: finding a class, understanding what is due, sharing materials, and receiving feedback. A dark-first interface gives the product a quieter, focused atmosphere that works well in evening study sessions and reduces glare, while preserving the familiar, approachable feel of a classroom workspace.

The primary color, a deep forest green, anchors the visual identity without making every surface feel like an action. Layered charcoal-green backgrounds and subtle borders distinguish navigation, cards, and dialogs with restrained contrast. A soft green accent highlights links, selected states, and important progress cues. Semantic success, warning, and danger colors are reserved for statuses that need clear meaning.

Google Sans gives page titles and key interface labels a distinctive but familiar character; Roboto keeps assignment details, instructions, and controls highly legible at small sizes. The type scale emphasizes clarity over dramatic display, with comfortable body leading to support longer instructions and feedback.

An 8px-based spacing system makes class streams, assignment lists, and forms predictable to scan. Compact spacing helps students see more work at once, while larger gaps separate tasks and page sections. Rounded corners and restrained shadows soften the interface without making it feel playful or distracting.

## 1. Visual Theme & Atmosphere

Create a focused, calm, and dependable learning environment. The interface should feel like a well-organized digital classroom: practical first, welcoming second, decorative last.

- Use deep green-charcoal surfaces as the default canvas, with slightly lighter surfaces for cards, menus, and dialogs.
- Keep borders subtle but visible; use spacing and alignment before adding dividers.
- Use the accent color sparingly for links, selected navigation, progress, and primary emphasis.
- Treat class identity as useful context. Use simple color blocks, restrained patterns, or a class image in the class banner without reducing text legibility.
- Avoid excessive gradients, ornamental illustrations, dense dashboards, and large areas of saturated color.
- Maintain clear hierarchy for class name, assignment title, due date, and status.

## 2. Color System

Use the dark palette as the default. Apply colors consistently by role rather than assigning colors arbitrarily to individual screens.

| Token | Value | Role |
|---|---|---|
| Primary | `#393C45` | Brand anchor and primary button fill |
| Primary hover | `#494c56` | Hover and pressed emphasis for primary actions |
| On-primary | `#f4f7f4` | Text and icons on primary surfaces |
| Background | `#101512` | App canvas and page background |
| Surface | `#1b231e` | Cards, panels, inputs, and menus |
| Border | `#354039` | Dividers, input outlines, and card edges |
| Text | `#f0f4f1` | Headings and primary content |
| Text muted | `#b2bdb5` | Supporting text, metadata, and placeholders |
| Accent | `#a8d5b5` | Links, selected states, and progress highlights |
| Success | `#81c995` | Submitted, returned, or completed states |
| Warning | `#f4c66a` | Upcoming due dates and attention-needed states |
| Danger | `#ff8a80` | Overdue, failed, or destructive states |

- Use `background` for the page canvas and `surface` for content containers. Use a higher elevation or a distinct surface treatment for popovers and dialogs.
- Use `accent` for interactive links and selected indicators, not for long blocks of text or large decorative fills.
- Pair semantic status colors with a label or icon. Never convey submission state, lateness, or errors through color alone.
- Keep borders visible against both background and surface. Avoid relying on a one-pixel color change to communicate selection.
- If a light theme is added, define a complete, separately tested token set. Do not simply invert these values.

## 3. Typography

Use Google Sans for prominent headings and Roboto for interface and reading text. If the preferred font is unavailable, fall back to the specified system stack without shifting layout or reducing legibility.

- **Display (56px):** Use sparingly for major page-level titles or empty-state messages on spacious layouts. Reduce to 40px on narrow screens.
- **Heading (32px):** Use for page titles, class names, and major dialog headings. Use 24px or 20px for nested sections as needed.
- **Body (15px):** Default for instructions, announcements, assignment details, and discussion content. Keep line length comfortable for reading.
- **Small interface text (12–13px):** Use for timestamps, labels, and compact metadata; do not use it for essential instructions or status without sufficient contrast.
- **Monospace (13px):** Reserve for code snippets or technical content submitted as coursework.
- Use sentence case for headings, buttons, and labels. Prefer plain language such as “Turn in” or “Mark as done.”
- Avoid long runs of uppercase text, overly tight leading, and low-contrast placeholder text.

## 4. Components & Patterns

1. **Top app bar**
   - Use a stable, compact header with menu control, product identity, and account or help actions.
   - Keep the header visually distinct from the page without a heavy shadow.
   - Ensure icon-only controls have accessible names and touch-sized hit areas.

2. **Primary and secondary buttons**
   - Primary action: `#17211a` fill with `#f4f7f4` text, such as “Turn in” or “Create.”
   - Hover: transition to `#26372b`; pressed: reduce brightness slightly without changing text readability.
   - Secondary action: transparent or surface fill with a visible border and high-contrast text.
   - Destructive actions use the danger color and should require confirmation when consequences are difficult to reverse.
   - Provide disabled, loading, hover, pressed, and keyboard-focus states. Do not use color alone to indicate disabled status.

3. **Class cards**
   - Show class name, teacher, and a small amount of class context at a glance.
   - Keep class imagery or color treatments subordinate to readable text.
   - Make the full card clickable only when it has one clear destination; otherwise use explicit links and actions.
   - Use a visible focus state and a consistent card height where cards appear in a grid.

4. **Class navigation**
   - Include clear destinations for classes, calendar, to-do work, and archived classes where relevant.
   - Show the active location with an accent marker plus a text or shape change.
   - Allow navigation to collapse on smaller screens without hiding the current location or essential actions.

5. **Assignment cards and lists**
   - Prioritize assignment title, class, due date, and status in that order.
   - Use consistent status labels such as “Assigned,” “Turned in,” “Returned,” and “Missing.”
   - Group work by due date or class, and provide a meaningful empty state when no work is due.
   - Keep overflow actions separate from the main assignment link.

6. **Status chips**
   - Use compact pill-shaped labels with readable text and adequate contrast.
   - Pair warning, success, or danger color with a concise status label; avoid icon-only status.
   - Do not use status chips as buttons unless their interactive behavior is clear and they have focus states.

7. **Forms and text fields**
   - Use a surface fill, visible border, persistent label, and a clear focus treatment.
   - Keep helper text and validation messages close to their field.
   - Show errors in text with a corrective suggestion when possible. Preserve entered content after validation errors.
   - Use suitable input types and autocomplete to reduce effort for students and educators.

8. **Assignment detail and submission panel**
   - Separate instructions, attachments, class comments, and submission controls into clearly labeled sections.
   - Keep the main action, such as “Turn in,” visible without making it compete with the assignment content.
   - Confirm submission state with both a clear status label and an appropriate action change, such as “Unsubmit” when supported.
   - Make attachments identifiable by name and type, with clear download or open actions.

9. **Dialogs, menus, and confirmations**
   - Use dialogs for focused decisions, such as confirming a destructive action or choosing an attachment.
   - Keep menus short, keyboard navigable, and anchored to their triggering control.
   - Return focus to the invoking control when a dialog closes; support Escape where appropriate.
   - Do not place long assignment instructions inside a small modal.

10. **Loading and empty states**
    - Use skeletons for content whose final structure is known; use a small progress indicator for brief actions.
    - Keep empty states concise and helpful, with a next step when one exists.
    - Avoid indefinite spinners without an explanatory label. Announce important loading and completion states to assistive technology.

## 5. Spacing & Layout

Use an 8px spacing base with 4px increments for fine adjustments. Apply spacing consistently to make dense schoolwork easier to scan.

- **Page width:** Use a content max width of approximately 1200px for class lists and dashboards. For reading-heavy assignment instructions, use a narrower 680–760px measure.
- **Desktop gutters:** 32px minimum on wide layouts; 24px for typical laptop widths.
- **Mobile gutters:** 16px minimum, increasing to 20px where space allows.
- **Grid:** Use a 12-column desktop grid with 24px gutters. Class cards may use a responsive 2–4 column layout; collapse to one column on narrow screens.
- **Vertical rhythm:** Use 24–32px between major sections, 16px between related controls, and 8–12px between a label and its content.
- **Lists:** Use consistent row heights and align titles, due dates, and status indicators to stable columns when the viewport permits.
- **Responsive behavior:** Reflow content rather than shrinking text or controls. Preserve the order of information and the prominence of deadlines on small screens.
- **Density:** Prefer compact metadata and generous section separation. Do not compress essential tap targets to fit more items on screen.

## 6. Motion & Interaction

Motion should clarify cause and effect, not compete with learning content.

- Use 120ms transitions for hover and pressed states, 200ms for menus and small panels, and up to 320ms for larger layout changes.
- Use the easing curve in the token set for fades, surface changes, and modest movement.
- Hover states may change surface tone, border, or elevation subtly. Do not rely on hover to reveal essential actions on touch devices.
- Menus and dialogs should appear promptly with a short fade or small scale transition. Avoid large slide distances and overshoot.
- On submission, provide immediate feedback and update the visible status after confirmation.
- Use skeleton loading for stable content layouts and reserve indeterminate progress for genuinely unknown wait times.
- Respect `prefers-reduced-motion`; remove nonessential movement and shorten transitions while retaining state changes and feedback.

## Accessibility

### Contrast Ratios

Approximate WCAG contrast ratios for the dark palette:

| Foreground / background | Approx. ratio | Guidance |
|---|---:|---|
| Text `#f0f4f1` on background `#101512` | 16.5:1 | Exceeds WCAG AAA for normal text |
| Text `#f0f4f1` on surface `#1b231e` | 14.7:1 | Exceeds WCAG AAA for normal text |
| Muted text `#b2bdb5` on background `#101512` | 8.6:1 | Exceeds WCAG AAA for normal text |
| Accent `#a8d5b5` on background `#101512` | 10.5:1 | Exceeds WCAG AAA for normal text |
| On-primary `#f4f7f4` on primary `#17211a` | 15.9:1 | Exceeds WCAG AAA for normal text |
| Text `#f0f4f1` on primary-hover `#26372b` | 12.7:1 | Exceeds WCAG AAA for normal text |

Ratios are approximate and should be checked against rendered colors, including opacity, overlays, and state changes. WCAG AA requires at least 4.5:1 for normal text and 3:1 for large text and meaningful non-text interface elements. Verify semantic colors against their actual text and surface pairings before use.

### Minimum Requirements

- Touch target: 44×44px minimum.
- Focus indicator: `#a8d5b5` outline, 2px, 2px offset.
- Focus contrast: approximately 10.5:1 against `#101512`; verify the indicator against each adjacent surface.
- Provide visible keyboard focus for every interactive element; do not remove outlines without an accessible replacement.
- Use semantic headings, landmarks, labels, and status announcements. Ensure controls work with keyboard and screen readers.
- Maintain readable zoom and reflow at 200% without requiring horizontal scrolling for ordinary content.

### Motion

- Respects `prefers-reduced-motion`: yes.
- Preserve essential feedback when motion is reduced; communicate state changes through text, shape, or color as well.

### Notes

- Student work, teacher feedback, and class membership can be sensitive. Keep private information out of decorative previews and ensure visibility follows the product’s access rules.
- Use explicit labels for overdue and submitted work, including screen-reader-readable status text.
- Do not rely on color, position, or iconography alone to distinguish classes or communicate assignment state.