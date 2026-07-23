---
title: "feat: Enable main section background image"
type: feat
status: completed
date: 2026-07-23
origin: https://linear.app/avo-hq/issue/AVO-1517/enable-main-section-background-image
---

# feat: Enable main section background image

## Overview

Give users a first-class way to set the main content section (`<main id="main-content">`) background to an image (or gradient / any CSS background value), configured through the existing `config.appearance` pipeline rather than requiring hand-written CSS overrides.

## Problem Frame

AVO-1517: *"Users should be able to change the main section background to an image. It may already be possible with CSS, but that needs to be tested and confirmed."*

**Confirmed during research:** it is **partially** possible today, but not clean.
- `.main-content` currently applies its background via `@apply ... bg-(--color-main-content-background)` (`app/assets/stylesheets/css/layout.css:66`), which compiles to `background-color: var(--color-main-content-background)`.
- A `background-color` cannot hold a `url(...)`, so setting the existing var to an image does nothing. Users can override `.main-content { background-image: url(...) }` via `avo-overrides.css` or the `_head` partial, but there is **no config knob** and the color/image layering is left to the user to get right.

This plan adds a dedicated `appearance.main_content_background` option that plugs into the already-established `brand_css_overrides` → `_appearance_overrides.html.erb` pipeline (the same one that powers `neutral_colors` / `accent_colors`).

## Requirements Trace

- R1. A user can configure the main content section background to an image via `config.appearance` — no manual CSS override required.
- R2. The value is flexible enough to accept an image (`url(...)`), a gradient, or any CSS `background` value.
- R3. When unset, the main content background is visually **unchanged** (still the themed `--color-main-content-background` color, correct in light and dark mode).
- R4. The configured background survives the theme picker (light/dark, accent/neutral switches) the same way brand color overrides do.

## Scope Boundaries

- **Non-goal:** a UI control in the appearance picker to set the background image at runtime. This is initializer-config only, matching `logo`/`chart_colors`.
- **Non-goal:** per-resource or per-page backgrounds. One app-wide setting.
- **Non-goal:** Rails asset-pipeline resolution of a bare asset name (e.g. `"bg.png"` → `image_url`). The value is passed through as raw CSS; users reference assets with `url('/...')` or a full URL. (Deferred — see Open Questions.)
- **Non-goal:** changing the breadcrumbs bar, which also reads `--color-main-content-background` (`css/components/breadcrumbs.css`). It stays color-based and untouched.

## Context & Research

### Relevant Code and Patterns

- **Main section element:** `app/views/layouts/avo/application.html.erb:68` — `<main id="main-content" class="main-content">`.
- **Background rule to change:** `app/assets/stylesheets/css/layout.css:61-66` — `.main-content { @apply ... bg-(--color-main-content-background) ... }`.
- **Default var:** `app/assets/stylesheets/css/variables.css:111-115` — `--color-main-content-background: var(--color-primary);` (resolves per-scheme via `--color-primary`).
- **Config option home:** `lib/avo/configuration/appearance.rb` — attrs, `DEFAULTS`, `initialize`, and `brand_css_overrides` / `brand_declarations` (lines 123-161) that build the `@layer base { :root { ... } }` inline style.
- **Config → CSS injection:** `app/views/avo/partials/_appearance_overrides.html.erb` — emits the `<style>` tag with a CSP nonce, rendered last in `<head>` (`application.html.erb:44`).
- **Config reader:** `lib/avo/configuration.rb:311-316` — `appearance` accessor.

### Institutional Learnings

- **Follow the brand-color-overrides feature exactly** (origin: `external/avo/docs/plans/2026-05-06-001-feat-brand-color-overrides-plan.md`). It established the pattern: appearance attr → `brand_declarations` emits `--var: value;` → wrapped in `@layer base { :root {} }` so it beats Avo defaults but still loses to a user-selected `.accent-theme-*` (later layer). Reuse this so R4 comes for free.

### Layering Note (why `@layer base` matters — from appearance.rb:110-122)

`theme < base < components` ordering guarantees the `:root` override beats Avo's default `:root`/`.dark` palette while a later-layer theme class still wins. Emitting the new var in the same `@layer base { :root {} }` block keeps that guarantee.

## Key Technical Decisions

- **Raw CSS value, single var, `background` shorthand.** The `.main-content` rule switches from the color-only `bg-(--color-main-content-background)` to `background: var(--main-content-background, var(--color-main-content-background))`. When the option is unset the fallback resolves to the existing themed color (R3). When set, `brand_css_overrides` emits `--main-content-background: <value>` at `:root`. **Do not** declare `--main-content-background` locally on `.main-content` — a local default would shadow the `:root` override and break the feature.
  - *Rationale:* one var, background shorthand accepts color/image/gradient/full shorthand (R2), and the `var(..., fallback)` keeps unset behavior identical (R3). Accepting raw CSS avoids needing asset-pipeline access inside the pure-string `Appearance` class.
- **Trigger the style tag on this option too.** `brand_css_overrides` currently returns `nil` unless `neutral_colors`/`accent_colors` is set. Extend the guard so a set `main_content_background` also emits the block.
- **Keep `--color-main-content-background` as the fallback layer.** Users who want an image *with* a color behind it (for load/transparency) can write `url('/bg.png') center/cover no-repeat, var(--color-main-content-background)` themselves. No extra knobs — YAGNI.

## Open Questions

### Resolved During Planning

- *Is it already possible with CSS?* — Partially (manual `.main-content` override); not via config and not cleanly, because the current rule is `background-color`. This plan makes it first-class. (Answers the ticket's "test and confirm".)
- *Which var / rule carries it?* — New `--main-content-background`, consumed by a `background` shorthand on `.main-content`, fallback to `--color-main-content-background`.

### Deferred to Implementation

- Whether to also set sensible default `background-size`/`background-position`/`background-repeat` on `.main-content` so a bare `url(...)` value looks reasonable without the user specifying them. Decide when implementing by eyeballing a bare-`url()` value in the browser; if it tiles/misaligns, add `background-size: cover; background-position: center; background-repeat: no-repeat;` as declared (non-shorthand) properties on `.main-content` — they don't fight the `background` shorthand only if placed *after* it, so order matters. Verify in-browser.
- Asset-name convenience resolution (`"bg.png"` → `image_url`) — deferred as a possible follow-up; would require passing view/asset context into the override generation, a larger change than this ticket warrants.

## Implementation Units

- [ ] **Unit 1: Add the `main_content_background` appearance option and emit its CSS var**

**Goal:** Users can set `config.appearance = { main_content_background: "..." }` and have it emitted as a `--main-content-background` declaration through the existing override pipeline.

**Requirements:** R1, R2, R4

**Dependencies:** None

**Files:**
- Modify: `lib/avo/configuration/appearance.rb`
- Test: `spec/lib/avo/configuration/appearance_spec.rb`

**Approach:**
- Add `:main_content_background` to the `attr_reader` list and assign it in `initialize` from `config[:main_content_background]` (default `nil`; no `DEFAULTS` entry needed since nil = unchanged).
- In `brand_css_overrides`, change the early-return guard to also stay when `main_content_background` is present: return `nil` only if `neutral_colors.nil? && accent_colors.nil? && main_content_background.nil?`.
- In `brand_declarations`, append `"  --main-content-background: #{main_content_background};"` when `main_content_background` is set. It sits in the same `@layer base { :root {} }` block as the color overrides.
- No new validation required (freeform CSS string); mirror how `logo` (a freeform string) is handled — no validator.

**Patterns to follow:**
- `neutral_colors` / `accent_colors` handling in `initialize`, `brand_css_overrides`, `brand_declarations` (appearance.rb:63-64, 123-161).

**Test scenarios:**
- Happy path: `Appearance.new(main_content_background: "url('/bg.png') center/cover no-repeat")` → `brand_css_overrides` includes `--main-content-background: url('/bg.png') center/cover no-repeat;` inside `@layer base { :root {` .
- Happy path: value works for a gradient too, e.g. `"linear-gradient(...)"` is emitted verbatim.
- Edge case: `main_content_background` unset **and** no neutral/accent colors → `brand_css_overrides` returns `nil` (no `<style>` emitted).
- Edge case: `main_content_background` set while `neutral_colors`/`accent_colors` unset → override string is still produced and contains only the `--main-content-background` line (proves the guard change).
- Integration: `main_content_background` set **together with** `accent_colors` → both `--main-content-background` and `--color-accent` appear in the same emitted block.

**Verification:** `appearance_spec.rb` passes; the emitted string is wrapped in `@layer base { :root { ... } }`.

- [ ] **Unit 2: Make `.main-content` render the configurable background**

**Goal:** `.main-content` uses the new var with the themed color as fallback, so an unset config is visually identical and a set config paints the background.

**Requirements:** R2, R3

**Dependencies:** Unit 1 (var name must match)

**Files:**
- Modify: `app/assets/stylesheets/css/layout.css` (the `.main-content` rule, ~line 66)

**Approach:**
- Replace `bg-(--color-main-content-background)` inside the `@apply` with a plain declaration `background: var(--main-content-background, var(--color-main-content-background));` (either as a Tailwind arbitrary `bg-[...]` utility or a raw CSS property outside `@apply` — prefer raw CSS property for readability of the nested `var()` fallback; place it right after the `@apply` line).
- Do **not** declare `--main-content-background` on `.main-content` (would shadow the `:root` override).
- Leave `--color-main-content-border` and every other utility in the rule unchanged.
- Leave `breadcrumbs.css` untouched (still reads `--color-main-content-background`).

**Execution note:** This is a CSS/visual change — verify in the browser (see Verification), not just via unit test.

**Patterns to follow:**
- Existing arbitrary-value background usage in the same rule; `var(..., fallback)` pattern used elsewhere in `variables.css`.

**Test scenarios:**
- Test expectation: none (CSS-only) for a unit test. Covered by the browser/visual verification below and by Unit 3's request spec proving the var reaches the page.

**Verification:**
- With no `main_content_background` configured, the main panel background looks identical to before in both light and dark mode.
- With `config.appearance = { main_content_background: "url('/some-image.png') center/cover no-repeat" }` set in the dummy app, the image renders across the main content panel; toggling light/dark and switching accent themes does not remove it (R4).

- [ ] **Unit 3: Prove the option renders into the page `<head>`**

**Goal:** End-to-end coverage that a configured `main_content_background` reaches the rendered `_appearance_overrides` `<style>` tag.

**Requirements:** R1

**Dependencies:** Unit 1

**Files:**
- Modify: `spec/requests/avo/appearance_overrides_request_spec.rb`

**Approach:**
- Add a context that stubs `Avo.configuration.appearance.brand_css_overrides` to return a block containing `--main-content-background: url('/bg.png') ...;` (mirror the existing stubbed-overrides context) and asserts the response body includes the declaration inside a `<style>` tag. This mirrors the existing neutral/accent override request spec exactly.

**Patterns to follow:**
- `spec/requests/avo/appearance_overrides_request_spec.rb:22-52` (the "when overrides are configured" context).

**Test scenarios:**
- Integration: request to an Avo page with `brand_css_overrides` returning a `--main-content-background` block → response body contains `--main-content-background:` within a `<style>` tag.

**Verification:** request spec passes.

- [ ] **Unit 4: Document the option and update the initializer template**

**Goal:** Users discover the option in the initializer and docs.

**Requirements:** R1

**Dependencies:** Unit 1

**Files:**
- Modify: `lib/generators/avo/templates/initializer/avo.tt` (the `config.appearance` block, ~line 141-159)
- Modify: `docs/docs/4.0/branding.md` (workspace docs site — the branding/appearance page)

**Approach:**
- Add a commented `#   main_content_background: "url('/my-background.png') center/cover no-repeat",` line to the appearance block in `avo.tt` (per the project's configuration rule: every `config.something` value must appear in the initializer template).
- In `branding.md`, add a short subsection under the appearance/branding options explaining `main_content_background`: that it accepts any CSS `background` value (image, gradient, shorthand), that images use `url(...)`, and that it layers over the themed color (include the `..., var(--color-main-content-background)` fallback tip). Include a light/dark note (single value applies to both, like brand colors).

**Test scenarios:**
- Test expectation: none — docs and initializer template comment, no behavioral code.

**Verification:** `avo.tt` shows the new commented option; `branding.md` renders the new subsection (optionally `npx vitepress build docs`).

## System-Wide Impact

- **Interaction graph:** Only `.main-content` background rendering and the `_appearance_overrides` `<style>` output change. Breadcrumbs bar (shares `--color-main-content-background`) is deliberately untouched and unaffected.
- **API surface parity:** `main_content_background` is a new optional key on the same `config.appearance` hash — additive, no breaking change. Existing configs (no key) behave identically (R3).
- **State lifecycle risks:** None — pure config-to-CSS, no persistence or runtime state. (The `persistence: :database` appearance path stores scheme/neutral/accent selections, not this static option; no change there.)
- **Unchanged invariants:** `--color-main-content-background` and its default (`variables.css:115`) are unchanged; it remains the fallback and the breadcrumbs color source. The theme-picker layering behavior is preserved by reusing the `@layer base { :root {} }` mechanism.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Local `--main-content-background` default on `.main-content` would shadow the `:root` override and silently break the feature. | Explicitly do NOT declare it locally; use `var(--main-content-background, var(--color-main-content-background))` fallback only. Called out in Unit 2. |
| A bare `url(...)` value tiles or misaligns without size/position. | Deferred decision in Open Questions — add `background-size/position/repeat` defaults after eyeballing; keep them as declared props ordered after the shorthand. |
| Freeform CSS value is injected into an inline `<style>`. | Same trust model as existing `neutral_colors`/`accent_colors`/`logo` — values come from the app's own initializer (developer-controlled), emitted with a CSP nonce. No new user-facing input surface. |
| `background` shorthand resets `background-color`. | Intended — the shorthand's own `var()` fallback supplies the themed color, so unset state is unchanged; verified in the browser. |

## Documentation / Operational Notes

- Docs: `docs/docs/4.0/branding.md` updated (Unit 4). Confirmed the relevant page exists (`appearance.md`, `appearance-api.md`, `branding.md` under `docs/docs/4.0/`); place the option with the other appearance branding options.
- No migration, rollout, or monitoring concerns.

## Sources & References

- **Origin issue:** [AVO-1517](https://linear.app/avo-hq/issue/AVO-1517/enable-main-section-background-image)
- Pattern reference: `external/avo/docs/plans/2026-05-06-001-feat-brand-color-overrides-plan.md`
- Code: `lib/avo/configuration/appearance.rb`, `app/assets/stylesheets/css/layout.css:61-66`, `app/assets/stylesheets/css/variables.css:111-115`, `app/views/avo/partials/_appearance_overrides.html.erb`
- Tests: `spec/lib/avo/configuration/appearance_spec.rb`, `spec/requests/avo/appearance_overrides_request_spec.rb`
