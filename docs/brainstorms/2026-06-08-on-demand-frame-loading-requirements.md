---
date: 2026-06-08
topic: on-demand-frame-loading
---

# On-Demand (Manual) Turbo Frame Loading for Tabs and Associations

## Problem Frame

Resource Show pages can carry a lot of content. Today, content that lives in a
Turbo Frame supports two loading modes:

- **`eager`** — load immediately with the page (default for associations).
- **`lazy`** — load automatically when the frame scrolls into the viewport
  (Turbo's native `loading="lazy"`; opt-in for tabs via `lazy_load: true`).

Neither mode lets the user *decide* whether expensive content is fetched. A tab
that runs a heavy query, hits an external API, or renders a large association
still loads the moment it becomes visible — even if the user never needed it.
This wastes server work and slows the page for content that is often ignored.

We want a **third loading mode** — **`manual`** (on-demand) — where the frame
renders a placeholder with an explicit **Load** button, and the content is
fetched only when the user clicks it. ("Manual" is the mode name used throughout
this document.) This applies to **tabs** and
**associations** (`has_many` / `has_one` / `has_and_belongs_to_many`). Panels
are out of scope (they are not Turbo Frames today).

## Loading Modes (after this change)

| Mode | When content loads | Existing? | Surface today |
|---|---|---|---|
| `eager` | Immediately with the page | Yes | Associations (default), tabs without `lazy_load` |
| `lazy` | When the frame scrolls into the viewport | Yes | Tabs (`lazy_load: true`), associations (`turbo_frame_loading: :lazy`) |
| `manual` | Only when the user clicks a **Load** button | **New** | Tabs + associations |

**When to choose `manual` over `lazy`:** `lazy` auto-fetches as soon as the frame
becomes visible — on scroll, or when a tab is revealed. `manual` withholds the
fetch **even when the content is on screen**, requiring an explicit click every
time. Reach for `manual` when the content is expensive *and* you want the user to
consciously opt in; `lazy` remains the better default when "load it once it's
seen" is acceptable.

## Manual Behavior by Surface

`manual` means **one** thing on every surface: the frame renders a placeholder
with a **Load** button and fetches nothing until that button is clicked. No
auto-fetch on scroll, on page load, or on tab reveal.

**Associations (`has_many` / `has_one` / `has_and_belongs_to_many`)**
- The frame renders a placeholder (title/description + **Load** button).
- Nothing is fetched until the button is clicked. The association frame is always
  present in the layout, so the button is always visible.

**Tabs — full per-tab gating**
- *Every* tab marked `manual` renders its own placeholder + **Load** button.
  Whichever tab is revealed first — by default, deep link, or a
  localStorage-restored selection — shows its button instead of auto-loading.
- Revealing a manual tab (clicking it, or restoring it from localStorage) does
  **not** fetch — it shows that tab's button. The user clicks Load to fetch.
- Consequence: browsing a manual tab is a two-step flow (open the tab, then
  click Load). This is intended — it is the cost of guaranteeing nothing
  expensive runs without an explicit request, and it is why `manual` is opt-in.
- Because every revealed tab shows a button, there is **no** "which tab is really
  active" ambiguity between the server render and client-side localStorage
  restoration — the divergence that made an active-tab-only design unsound
  simply does not arise here.

## Requirements

**Loading Mode & DSL**
- R1. Introduce a `manual` loading mode as a peer to `eager` and `lazy`. It is
  opt-in; no existing tab or association changes behavior unless the developer
  sets it.
- R2. Manual mode is available on tabs and on `has_many` / `has_one` /
  `has_and_belongs_to_many` association fields.
- R3. Manual mode applies in **display/show views only**, consistent with how
  `lazy_load` is gated today. Edit/New views must still render all fields so
  forms submit completely.

**Trigger & Loading Behavior**
- R4. A manual frame renders a placeholder (title/description + **Load** button)
  and fetches nothing until the user activates the button. This per-frame
  guarantee is uniform across associations and tabs.
- R5. Activating the button replaces the placeholder with the frame's real
  content, showing a loading indicator during the request (reuse the existing
  loading affordance).
- R6. Every tab marked `manual` shows its own **Load** button when revealed and
  fetches nothing until clicked — including the tab visible on initial load.
  Revealing a tab (click, deep link, or localStorage-restored selection) shows
  its button; it never auto-fetches.
- R7. Once loaded, content **stays loaded while the user stays on the page** —
  switching tabs away and back keeps it (it remains in the DOM). This guarantee
  covers in-page tab switching (CSS show/hide) only. A hard reload re-defers and
  shows the button(s) again. Behavior across Turbo back/forward / page-cache
  restoration is a separate case to verify in planning (the DOM-only approach
  does not automatically guarantee it). No server-side or localStorage memory of
  the load is required.

**States & Resilience**
- R8. If the load request fails, the frame shows a short inline error message
  (e.g. "Couldn't load Orders") with a **Retry** button in place of the original
  Load button — not the generic `failed_to_load` error page, and not a silent
  return to the pristine placeholder. Retry re-issues the same request.
- R9. The **Load** button must be keyboard-focusable and screen-reader labeled
  (e.g. "Load <title>"), consistent with recent focus-visibility work.

**Labeling**
- R10. The placeholder shows a sensible default label derived from the
  tab/association name (e.g. "Load Orders").

## Success Criteria

- A developer can mark a tab or association as `manual` and, on the Show page,
  see a placeholder with a **Load** button instead of auto-fetched content.
- No network request is made for *any* manual frame — association or tab,
  including a revealed tab — until its button is clicked (verifiable in the
  network panel).
- Revealing a manual tab shows its Load button; it never auto-fetches.
- After loading, switching tabs and returning keeps the content without
  re-fetching; a full page reload restores the button(s).
- A failed load shows an inline error + **Retry**, and retrying succeeds once the
  underlying issue clears.
- Existing `eager` and `lazy` tabs/associations are unchanged.
- The button is operable by keyboard and announced by assistive tech.

## Scope Boundaries

- **Panels are out of scope.** They are not Turbo Frames today; making them
  deferrable is a separate, larger effort.
- **No page-level "Load all" control in v1.** Per-frame buttons only. A bulk
  trigger can follow if users ask.
- **No cross-reload memory.** We will not persist "user loaded this" to
  auto-load on return visits; that would partly defeat the purpose.
- **Edit/New views unaffected** — manual is display-only; the mode is ignored in
  edit/create contexts even if configured, so forms still render all fields.
- **Two-click tab browsing is intended, not a flaw.** With full per-tab gating,
  opening a manual tab and then loading it is two actions. A one-click "reveal =
  load" variant is explicitly *not* offered — it would reintroduce the auto-fetch
  this feature exists to prevent.
- Browser find-in-page (Ctrl+F), print, and full-page export will not see
  unloaded manual content. This is an accepted, inherent consequence of
  deferring the fetch (the same is already true of `lazy` content that hasn't
  scrolled into view).
- **Custom button label/description is a v1 non-goal.** The default label
  derived from the name (R10) is the only labeling deliverable; a developer-set
  custom label is a low-cost follow-up, tracked under Deferred to Planning.
- **Placeholder content preview is a v1 non-goal.** Surfacing a hint such as an
  association count in the placeholder (to help the user decide whether to load)
  is a separate capability — it needs its own cheap-query path — not a rendering
  decision. Revisit on demand.

## Key Decisions

- **Third mode, not a replacement:** `manual` joins `eager`/`lazy` rather than
  changing what `lazy` does. Opt-in, zero behavior change for existing apps.
- **Uniform full per-tab gating:** every manual tab shows its own Load button and
  never auto-fetches on reveal. Chosen over an active-tab-only design because the
  latter (a) barely improved on `lazy` — it only made the default tab wait for a
  click — and (b) had a real ambiguity: the server and client-side localStorage
  restoration could disagree on which tab is "active," so the button could land
  on a tab the user wasn't viewing while the visible tab auto-fetched. Per-tab
  gating dissolves that ambiguity and matches the original intent ("don't
  auto-load; require a button" — for tabs too). Cost: a two-click tab-browse.
- **Session-only persistence:** rely on the content staying in the DOM (tabs are
  CSS show/hide) rather than building memory of load state.
- **Scope held tight:** tabs + associations only; no panels, no load-all, no
  persistence — to ship a coherent v1 and expand from real demand.

## Alternatives Considered

- **Active-tab-only gating (defer just the initially-visible tab).** Considered
  and rejected. It barely beat `lazy` (only the default tab waited for a click;
  every other tab still auto-fetched on reveal), and it had a correctness hole:
  the server and client-side localStorage restoration can disagree on which tab
  is "active," so the Load button could render on a tab the user wasn't viewing
  while the visible tab auto-fetched. Full per-tab gating (the chosen design)
  avoids both problems.
- **Replace `lazy` with a button instead of adding a mode.** Rejected — it is a
  breaking behavior change for every existing `lazy` tab/association.
- **Page-level "Load all" control.** Deferred (see Scope Boundaries) — adds
  partial-failure and layout complexity without proven demand.
- **Drop tabs from v1 (associations only).** Considered as a way to ship the
  unambiguous half first; rejected because "tabs too" is part of the original
  ask and full per-tab gating makes tabs well-defined, so there is no need to
  split them out.

## Dependencies / Assumptions

- Turbo has no native "load on click" frame mode. Unlike `eager`/`lazy` — which
  are just the `loading` attribute on a frame that already has a `src` — `manual`
  is structurally different: it is the **absence of `src` until a user action**.
  The existing `turbo_frame_loading` concern only returns a loading-attribute
  string, so it cannot express `manual` directly; manual loading will be
  implemented by rendering a frame without an eager `src` and setting it on
  button activation (exact mechanism is a planning concern).
- **An existing failure path conflicts with R8.** `app/javascript/application.js`
  intercepts `turbo:before-fetch-response` on HTTP 500 and rewrites the frame's
  `src` to a `failed_to_load` error page. The conflict is *not* that a manual
  frame lacks a `src`: once the user clicks Load, the frame **does** get a `src`,
  so a 500 then flows through the same global handler, which has no way to know
  this frame wants inline error + Retry (R8) instead of the error page. R8 needs
  a **discriminator** (e.g. a `data-` attribute marking manual frames so the
  global handler skips them, or frame-scoped error handling) — not just a
  parallel failure path that silently coexists with the old one.
- The same file has a workaround stripping `loading="lazy"` off completed frames
  (Turbo bug #886); it must be reviewed so it does not interfere with manual
  frames.
- **Know which params actually select a tab.** Server-side tab selection keys off
  the `tab-group_<id>` param (the group param) plus `tab_turbo_frame` (used by
  `TabGroupComponent#is_not_loaded?`). The param literally named
  `active_tab_title` is written into URLs by the component but is **not** consumed
  server-side — an implementer who threads it expecting it to drive rendering
  will wire a no-op. The manual trigger must reproduce the params the component
  actually reads.
- **The initially-visible tab renders inline today (no `src`).** Currently only
  *non-active* tabs get `loading: :lazy` + `src`; the active tab's content is
  rendered inline via `TabContentComponent`. Under full per-tab gating, *all*
  manual tab frames become deferred placeholders (no `src`, with a button), so
  the mechanism is uniform — but note the active-tab branch is a different code
  path from today's lazy frames, not just "withhold a `src`."

## Outstanding Questions

### Resolve Before Planning
- (none — product behavior is settled)

### Deferred to Planning
- [Affects R1][Technical] Final DSL/API surface and naming. Today tabs use
  `lazy_load: true` and associations use `turbo_frame_loading: :lazy | "eager"` —
  inconsistent already. Decide how `manual` is expressed on each (e.g.
  `turbo_frame_loading: :manual` for associations; a tab option such as
  `lazy_load: :manual` or a dedicated key) and whether to unify the two.
- [Affects R4][Technical] Exact mechanism to defer then trigger the Turbo Frame
  load on click (frame without `src` + Stimulus sets `src`, vs. a link with
  `data-turbo-frame`), and how it threads the tab params from the assumption
  above.
- [Affects R8][Technical] How frame load failures surface in Turbo and the
  cleanest way to restore the button for retry — explicitly resolving the
  conflict with the existing `failed_to_load` 500-handler (see Dependencies).
- [Affects R6][Needs research] Confirm that a manual tab frame rendered without a
  `src` does **not** auto-fetch when revealed by `tabs_controller.js` (today
  non-active tabs carry `loading: :lazy` + `src` and fetch on reveal). Full
  per-tab gating removes the "which tab is active" ambiguity, but planning must
  verify the no-`src` placeholder survives reveal and Turbo back/forward without
  firing a request.
- [Affects R2][Technical] `has_one` with a **nil** value renders an
  attach/create empty-state panel today, not a frame. Decide what manual mode
  does on that path (Load button vs. fall through to the existing empty state).
- [Affects R1][Technical] Tabs store `@lazy_load` as a boolean and the
  `TabGroupComponent` is never passed a frame-loading mode; supporting `manual`
  on tabs needs a new tri-state attribute + component/template plumbing, not
  just a new accepted value. (Part of the DSL/API decision above.)
- [Affects R10][Technical] Whether to support a custom button label/description
  in v1 and how it's passed.

### Deferred to Planning — Design decisions
These are interaction-design gaps the requirements imply but do not yet specify;
they should be settled with the design pass during planning.
- **Placeholder anatomy.** What the unloaded placeholder looks like — reuse the
  loaded content's outer panel/field chrome (so only the inner body swaps, which
  also reduces layout shift) vs. a distinct lightweight block; button variant;
  whether a description line appears.
- **State distinction.** Visually separate the three states: never-loaded
  (button), mid-load (spinner / disabled button to prevent double-submit), and
  error. Mid-load should match the existing lazy-frame spinner.
- **Error-state copy & placement.** R8 already commits to inline error + a
  relabeled **Retry** button; the open part is the exact copy template and where
  the message sits relative to the button.
- **Layout shift.** A tall association expanding from a short placeholder shoves
  content below it; pick a stance (accept, min-height placeholder, or scroll
  anchor).
- **Focus management on load.** When the button is replaced by content, move
  focus to a sensible target and/or announce arrival via `aria-live` so keyboard
  and screen-reader users aren't dropped to `<body>` (extends R9).

## Next Steps
→ /ce:plan for structured implementation planning
