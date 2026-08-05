---
date: 2026-07-23
topic: resizable-sidebar
---

# Resizable Sidebar

## Problem Frame

Avo's sidebar is a fixed 256px. Long navigation labels wrap onto multiple lines — `.sidebar-link` is only `@apply py-1.5 my-px` with no `truncate`, `min-w-0`, or ellipsis handling, so nothing is clipped today, it just reflows. Users who want more room for the content area can only toggle the sidebar fully off — there's no middle ground. Making the divider draggable lets each user tune the sidebar to their own resource list without an all-or-nothing toggle.

The width flows from one CSS variable (`--sidebar-width`), but it does **not** flow through a single gate. The real consumers are:

| Consumer | Location | Breakpoint-gated? |
| --- | --- | --- |
| `.avo-sidebar { w-(--sidebar-width) }` | `layout.css:330` | **No** — applies at every breakpoint |
| `--sidebar-offset-size: var(--sidebar-width)` | `layout.css:50-52` | Yes — inside `@media (min-width: lg)` |
| `.main { padding-inline-start: var(--sidebar-offset-size) }` | `layout.css:57` | Inherits the above |
| `--top-navbar-start-notch-offset: var(--sidebar-offset-size)` | `layout.css:204` | Inside a `@container style(...)` query |

Only the *offset* inherits the existing `lg` gate; the sidebar's own width does not. So this feature is not merely "set one number and remember it" — it is a stored value plus a newly-gated derivation, because the stored width must apply at ≥lg and be ignored below it (R14).

## Requirements

**Resize interaction**

- R1. The boundary between the fixed sidebar and `.main-content` acts as a drag handle for resizing. Note the sidebar has no border of its own at ≥lg (`.avo-sidebar` is `border-e lg:border-none`); the visible seam on desktop is `.main-content`'s `border-s`, on a sibling element.
- R2. A faint divider line is visible at rest so the edge reads as an interactive boundary. It strengthens and reveals the grip on pointer hover, on keyboard focus, and for the whole duration of a drag.
- R3. The grab zone is at least 12px wide and straddles the boundary, so the effective travel is forgiving. It must not intercept clicks intended for sidebar links, the main-content edge, or the sidebar scrollbar.
- R4. Dragging tracks the pointer 1:1 with no perceptible lag. The existing `0.1s` padding/width transitions on `.main` and `.main-content` must not apply while dragging — they would make the sidebar rubber-band behind the cursor.
- R5. During a drag, text selection is suppressed and the cursor shows a column-resize affordance.
- R6. Double-clicking the handle resets the sidebar to the default width by clearing the stored value, so the sidebar resumes tracking whatever the product default is rather than being pinned to a copied-in number.
- R7. Releasing the pointer outside the window, or losing pointer capture, ends the drag cleanly at the last valid width rather than leaving the sidebar stuck in drag state.
- R8. Resizing is pointer-driven only. On coarse-pointer / no-hover devices at or above `lg` (e.g. landscape tablets), the handle is not rendered — the hover-reveal model has no meaning there and an invisible dead strip would swallow edge swipes.

**Bounds and defaults**

- R9. The default width and rendered layout stay exactly what they are today (256px). This is not a zero-impact change: R17 adds a focus stop and R3 claims a pointer-reactive strip on the sidebar edge, both of which affect users who never resize.
- R10. The sidebar clamps to a minimum of 200px and a maximum of `min(480px, 40vw)`. The viewport term guards the small-laptop case — a flat 480px at the 1024px breakpoint would consume 47% of the screen. Dragging past either bound pins the sidebar at the bound rather than overshooting and snapping back.
- R11. When a stored width exceeds the current viewport's effective max, it is clamped for display without overwriting the stored value, so widening the window restores the user's chosen width.

**Label overflow**

- R12. Sidebar link labels render on a single line with an ellipsis when they overflow, with the full label available on hover. This applies at every width — it fixes the actual reported pain directly and gives the 200px minimum a defined appearance rather than an emergent one.

**Persistence**

- R13. The chosen width persists in a cookie, in the same key namespace as the existing sidebar open/closed state. Unlike the existing sidebar-open cookie (which is written with no `expires` and is therefore session-only), this cookie is explicitly persistent — it carries a `max_age`, `path: "/"`, and `SameSite=Lax`, following the precedent in `app/helpers/avo/application_helper.rb:33`. The width survives a browser restart.
- R14. The cookie is written on drag end and on keystroke settle, not on every pointer move. A drag ended by losing pointer capture (R7) still persists its last valid width.
- R15. The width is applied server-side on first paint for cold loads and normal Turbo visits. The sidebar must never render at 256px and then jump to the stored width. Turbo restoration visits and prefetched responses are a known exception — see R16.
- R16. For Turbo snapshot restorations, prefetched responses, and other tabs opened before the resize, the stored width is reconciled client-side. The correction must be instant and untransitioned; an animated jump is not acceptable.
- R17. The cookie is user-controlled input. Its value must be parsed as an integer and clamped to the allowed range on read, before it reaches any rendered style. A malformed, missing, or out-of-range value falls back to the default. Raw cookie content is never interpolated into markup or CSS.

**Responsive behavior**

- R18. Below the `lg` breakpoint (1024px) the sidebar is not resizable and the handle is not rendered.
- R19. Below `lg` the sidebar renders at its default width regardless of the stored value. A 480px width chosen on a desktop must not produce a 480px overlay on a 375px phone screen. Because `.avo-sidebar`'s own width is ungated today, this gate is new work — see Key Decisions.
- R20. When the sidebar is closed, no handle is rendered and it is removed from the tab order entirely.

**Accessibility and internationalization**

- R21. The handle is keyboard operable: focusable, exposed as a separator with an orientation and current/min/max width, and resizable with arrow keys. Step is 16px per press, 64px with a modifier. It carries a translated accessible name (a new key in `lib/generators/avo/templates/locales/avo.en.yml`), and its reported current value updates as the width changes so assistive tech announces each step.
- R22. In RTL the handle sits on the correct edge and drag direction is inverted, so dragging away from the sidebar always widens it. Per project convention this uses `start`/`end`, never `left`/`right`.

### Handle behavior by state

| State | Handle rendered | Handle visible | Stored width applied |
| --- | --- | --- | --- |
| Desktop (≥lg), fine pointer, sidebar open | Yes | Faint at rest; grip on hover / focus / drag | Yes |
| Desktop (≥lg), fine pointer, sidebar closed | No | — | N/A |
| Desktop (≥lg), coarse pointer / no hover | No | — | Yes |
| Mobile (<lg), sidebar open | No | — | No — uses default |
| Mobile (<lg), sidebar closed | No | — | N/A |

## Success Criteria

- A user can drag the sidebar to a comfortable width, navigate to another page, and find it still at that width with no visible jump.
- A user bothered by a wrapped resource name can find the resize affordance without being told it exists.
- A user who never touches the divider sees the same layout as today, and never triggers a resize by accident while aiming at a sidebar link.
- Resizing feels immediate and direct — the sidebar edge stays under the cursor throughout the drag, including on a full index table at max `per_page`.
- The layout stays correct at both bounds: no overlapping navbar notch, no clipped content, no broken notch geometry at 200px or the effective max — checked at 1024px and at a typical 1440px viewport.
- The feature is fully usable by keyboard and correct in RTL.

## Scope Boundaries

- The right-hand resource sidebar (`Avo::ResourceSidebarComponent`) is not in scope. This is only the main navigation sidebar.
- The UI panel sidebar (`Avo::UI::PanelComponent`'s `.panel__sidebar`) is not in scope either, despite being the target of the prior-art branch. If a shared resize controller is ever wanted, that convergence is follow-up work.
- No cross-device sync. Width is per browser, not per user account.
- No collapse-to-icons / rail mode. Narrowing to 200px is not the same feature as an icon-only sidebar, and mixing them would balloon the scope.
- No per-resource or per-page widths. One width for the whole admin.
- No configuration API for host apps to change the min/max bounds or the default. If demand appears, that's a follow-up.
- No drag-to-close. Dragging to the minimum pins at 200px; closing stays the job of the existing toggle and `Shift+\` shortcut.

## Key Decisions

- **Cookie over localStorage**: The sidebar open/closed state is already read server-side, so a cookie reuses an existing, proven path. Note the original rationale for this choice was wrong: Avo *does* already ship a pre-paint inline script (`app/views/avo/partials/_color_theme_override.html.erb`) that reads localStorage before first paint to avoid FOUC, so "localStorage would flash" is not true here. The cookie still wins on reusing the existing path, at the accepted costs of being sent on every request, making layout HTML vary by cookie, and being shared across tabs.

- **Cookie over the appearance-settings hook**: Avo has a per-user preference mechanism — `Avo.configuration.appearance.persistence` (`:cookie | :database`) with host-supplied `load_settings` / `save_settings` blocks, wired through `Avo::Current.appearance_settings` and `Avo::AppearanceSettingsController`. It needs no migration; the host supplies the blocks. Sidebar width deliberately does **not** join it, to keep this change small. Accepted consequence: on hosts configured with `persistence: :database`, every UI preference syncs per-user except sidebar width. Revisit if that inconsistency draws complaints.

- **Borrow mechanics from the prior-art branch, don't merge it**: Branch `feature/resizable-sidebar` contains `panel_sidebar_resize_controller.js` plus handle CSS. Assessed and deliberately not adopted wholesale — it is a single local commit from 2026-02-26, never pushed (no PR), sitting 434 commits behind main, and it targets `Avo::UI::PanelComponent`'s `.panel__sidebar`, a different component from the main navigation sidebar. Rebasing it costs more than it returns. Two ideas are worth lifting verbatim:
  - **RTL delta inversion**: `const delta = isRtl ? (clientX - startX) : (startX - clientX)`, reading direction off `getComputedStyle(this.element).direction`. Satisfies R22's drag-direction half.
  - **Grab zone wider than the visual handle**: a narrow visual strip with `&::after { @apply absolute inset-y-0 -inset-x-1 }` expanding the hit area beyond it. Exactly the R3 pattern.

  Explicitly *not* carried over: `window.Avo.localStorage` persistence (R13 uses a cookie), `MIN_WIDTH = 240` with no max (R10), writing `sidebarTarget.style.width` directly rather than driving a CSS variable on the host so the whole layout reflows, the `hidden md:flex` gate (R18 needs `lg`, plus R8's coarse-pointer gate), separate `mousedown`/`touchstart` paths rather than unified pointer events with capture (R7), `bg-neutral-200` rather than Avo's semantic color tokens, and the complete absence of keyboard and ARIA support (R21).

- **Not resizable below `lg`**: The `lg` breakpoint is where the existing layout already gates `--sidebar-offset-size`, so the feature reuses a boundary the codebase already draws. It does not inherit that gate for free — `.avo-sidebar` applies `w-(--sidebar-width)` ungated at `layout.css:330`, and both the desktop and mobile sidebar instances read the variable from the same host. An inline `style="--sidebar-width: Npx"` on the host would also outrank any media query, so the stored value lands in a distinct variable (e.g. `--sidebar-width-stored`) from which `--sidebar-width` derives only inside the `min-width: lg` block.

- **Faint divider at rest**: A fully invisible handle has no discoverability path — users with the problem would never find the fix, and every success criterion could pass while nobody used the feature. A subtle always-present seam costs nothing visually and makes the edge read as interactive.

- **Ellipsis on labels**: The original problem framing said labels were truncated; they are not. Adding ellipsis + hover-full-text fixes the reported pain directly and is what makes a 200px minimum safe to offer.

- **Double-click resets to default**: A cheap escape hatch from an awkward width. Note this is *not* the editor convention — VS Code, Finder column view, and spreadsheet dividers all auto-size to fit content on double-click. Reset-to-default is justified on its own merits (simple, predictable, no measurement pass), not by appeal to convention.

- **Width stored in px**: Stored and applied as an integer pixel value, which keeps R17's validation trivial and R10's bounds unambiguous. Browser page zoom scales CSS px correctly. Ceiling: a host app that raises the root font size will scale the 256px default (`--spacing(64)` is rem-based) but not a stored width. Upgrade path is to store rem if that ever matters.

## Alternatives Considered

- **Install-wide `Avo.configuration.sidebar_width` instead of drag**: A config attribute plus a CSS variable, with no drag controller, pointer capture, ARIA separator, RTL inversion, cookie parsing, responsive gating, or reset gesture. Precedents exist (`sidebar_toggle_visible`, the `back_to_top` config hash). It solves the stated problem for every user of an install at a fraction of the permanent maintenance surface in a core gem all paid tiers inherit. Rejected because the value of this feature is per-user tuning — different people using the same Avo install want different widths, which an install-wide default cannot deliver. Worth revisiting if per-user demand turns out to be weaker than assumed.

## Dependencies / Assumptions

- Assumes `--sidebar-width` remains the source of truth for sidebar sizing and that everything downstream continues to derive from it — see the consumer table in the Problem Frame.
- **Verified:** no sidebar-path consumer hardcodes 256px / 16rem / w-64. The only `w-64` occurrences are in `color_scheme_switcher.css` and `resource_index_component.html.erb`, both unrelated to sidebar sizing. No remediation work is in scope on this assumption.
- Assumes the cookie is readable at render time for the layout that renders the sidebar host element.
- Host apps can override Avo CSS (`avo-overrides`, `brand_css_overrides`) and can replace the sidebar body entirely via `render_custom_sidebar?` / `avo-menu`. A host that redeclares `--sidebar-width` will defeat the stored preference. Not defended against.

## Outstanding Questions

### Resolve Before Planning

None. All product decisions are settled.

### Deferred to Planning

- [Affects R15][Technical] Which element carries the server-rendered width, and how it coexists with the `--sidebar-width` declaration in `layout.css` on the `[data-controller~="sidebar"]` host.
- [Affects R1][Technical] Which element hosts the handle, given `.avo-sidebar` has no border at ≥lg and the visible seam belongs to `.main-content`. Also how a 12px grab zone straddling that boundary interacts with `.main-content`'s `border-s` and its `rounded-ss` corner states.
- [Affects R4][Technical] Cleanest way to suspend the layout transitions during a drag without a visible snap when they're restored on release.
- [Affects R4][Technical] How pointer-move updates are coalesced, and whether the main-content offset updates live or is committed on release. Mutating `--sidebar-width` relayouts the whole main-content subtree on every move; the worst case to stay smooth on is a full index table.
- [Affects R19][Technical] Whether the mobile default is enforced purely in CSS via the breakpoint gate or needs explicit handling. Note `sidebar_controller.js` hardcodes `window.innerWidth < 1024` while the CSS uses `theme(--breakpoint-lg)` — the two can disagree by the scrollbar width at the boundary.
- [Affects R20, R21][Technical] Where the handle sits in the DOM/tab order, and how it coexists with the existing skip links. A closed desktop sidebar currently stays in the tab order (the initial `hidden` class is never re-applied by the toggle), so R20 may require fixing that pre-existing gap.
- [Affects R10][Needs research] Verify the navbar notch and main-content radius geometry at both 200px and the effective max. The notch pseudo-elements are fixed-size quarter-circles positioned by `inset-inline-start`, so they likely translate rather than deform — probably lower risk than it looks.
- [Affects R16][Needs research] Confirm the reconciliation hook for Turbo restoration and prefetch (`turbo:before-render` vs `turbo:load`) and that it lands before paint.
- [Affects R12][Needs research] Confirm ellipsis on labels does not break the hotkey badges, the active-item scroll-into-view logic, or the sidebar profile footer at 200px.

## Next Steps

→ `/ce:plan` for structured implementation planning
