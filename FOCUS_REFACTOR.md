# Focus-Visible Refactor — Working Notes

Unified every `:focus-visible` ring across the Avo admin into a single, accessible, outline-based design system. Replaces ~11 scattered per-component focus rules and ~4 WCAG-failing inline suppressions.

**Branch:** `4-dev` · **Status:** implementation complete, pre-merge verification pending.

---

## Next Actions — Merge Blockers

A clean ordered checklist for whoever picks this up next. Do these in order; nothing else blocks merge.

### 🔴 Must fix before merging

1. **Investigate "checkbox broken in table view"**
   Flagged by the author during this session but no concrete repro was captured. Steps to start:
   - Open `/avo/resources/posts` (or any resource with a boolean field in index view)
   - Check whether checkboxes render, align, and respond to click/keyboard
   - If the issue reproduces: determine whether the refactor caused it (check `checkbox.css` history — we stripped `:focus-visible` from the combined hover+focus selector and reorganized a no-op `:checked:focus-visible` rule) or whether it pre-exists
   - If caused by the refactor: fix before merge. If pre-existing: move to a follow-up ticket

2. **Revert the dummy-app test trigger**
   Delete the `before_save { raise ... if name == "trigger-backtrace" }` block in `spec/dummy/app/models/project.rb` (lines 43–48, clearly commented `TEMP: focus-ring audit trigger`). It was added to manually test the backtrace alert's close-button focus ring.

3. **Run the contrast gate (Topic 8 checklist)**
   Full list is in the "Final contrast gate" section below. Minimum:
   - Tab every surface in light AND dark mode in the audit preview
   - DevTools contrast picker: ring ≥3:1 vs. every background
   - Emulate `forced-colors: active` and `prefers-contrast: more` — both should render correctly
   - If any surface fails: add `.dark { --focus-outline-color: var(--color-blue-300); }` or per-surface override

4. **Decide preview cleanup**
   Per Topic 6 decision 6: the preview's "Focus CSS" column documents pre-refactor state (marked `bg-warning/5`). Either strip those annotations now or leave as historical reference and strip post-merge. Pick one.

### 🟡 Non-blocking — open as follow-up tickets

| Item | File / location | Why follow-up not blocker |
|---|---|---|
| Radio focus ring invisible after mouse click → Tab → Shift+Tab back to selected option. Arrow keys restore it. | `radio_field/edit_component.html.erb` — needs JS, not CSS | Browser `:focus-visible` heuristic — can't fix in CSS. Needs `element.focus({ focusVisible: true })` or accept the browser behavior. |
| Sidebar chevron alignment with inset focus ring (chevron crowded against ring's right edge) | `menu_controller.js` + `sidebar.css` | Polish issue, pre-existed before refactor |
| Sidebar group-header icon appears oversized (reported in screenshot) | `sidebar-icon` class, icon render path | Polish / unrelated render-path bug |
| `display_as: :tabs` radio field hides the input with `class: "hidden"` — keyboard users can't focus it at all | `radio_field/edit_component.html.erb:7` | Pre-existing WCAG 2.1.1 failure, not introduced by refactor |
| Boolean toggle variant uses `sr-only peer` — focus behavior on the toggle not explicitly verified | `boolean_field/edit_component.html.erb` | Needs manual verification |

---

## Why we did it

Before the refactor:

| Problem                                                                            | Impact                          |
| ---------------------------------------------------------------------------------- | ------------------------------- |
| 4 different focus-ring techniques in use (`box-shadow`, `ring-*`, `outline`, `::after` pseudo) | Visual inconsistency across the app |
| 4 ERB files with `focus:outline-hidden` and no replacement                         | **WCAG F78 violations** — keyboard users lose the focus indicator on those elements |
| `box-shadow`-based ring conflicted with decorative shadows (e.g. primary button gradient) | Button lost its gradient on focus |
| `box-shadow` ring got clipped by `overflow: hidden` parents (dropdown items)       | Ring barely visible, workarounds with `z-index` everywhere |
| Forced-colors mode stripped all rings                                              | Windows HCM users got no focus indicator |

After the refactor: **one rule, one token, one behavior** — accessible by default, overridable where needed.

---

## Design decisions locked

| # | Topic                    | Decision                                                                                     |
| - | ------------------------ | -------------------------------------------------------------------------------------------- |
| 1 | Token shape              | Outline-based (not box-shadow). Single color `var(--color-info)`, 2px width, 1px offset     |
| 2 | Fallbacks                | `:focus:not(:focus-visible) { outline: none }` reset, `prefers-contrast: more` → 3px + `currentColor`, `forced-colors: active` → `outline: 2px solid Highlight` |
| 3 | Specificity model        | Bare `:focus-visible` global rule (spec 0,0,1). Component overrides use plain class selectors (0,1,0+). State styles stay in `@layer component`. No `!important` anywhere |
| 4 | Clipping strategy        | Second token `--focus-outline-offset-inset: -2px` for `overflow: hidden` parents (dropdown items, color-scheme options, sidebar items) |
| 5 | Motion                   | Instant — no transitions on focus                                                            |
| 6 | Audit preview coverage   | 47 rows covering every focusable type + surface matrix + inset validation + DevTools testing note |
| 7 | Cleanup scope            | Same PR — token additions, global rule, per-component cleanup, ERB F78 fixes, legacy token removal |
| 8 | Final contrast gate      | **Deferred** to end of refactor (separate pass)                                              |

---

## Tokens (`variables.css`)

```css
--focus-outline-width:        2px;
--focus-outline-offset:       1px;
--focus-outline-offset-inset: -2px;
--focus-outline-color:        var(--color-info);
--focus-outline: var(--focus-outline-width) solid var(--focus-outline-color);
```

Legacy `--box-shadow-focus` removed.

---

## Global rule (`app/assets/stylesheets/css/focus.css` — new file)

```css
@layer base {
  :focus-visible {
    outline: var(--focus-outline);
    outline-offset: var(--focus-outline-offset);
  }

  :focus:not(:focus-visible) {
    outline: none;
  }

  /* Checkbox/radio nested in <label> — ring wraps the label + input */
  label:has(> input[type=checkbox]:focus-visible),
  label:has(> input[type=radio]:focus-visible) {
    outline: var(--focus-outline);
    outline-offset: var(--focus-outline-offset);
    border-radius: 0.375rem;
  }
  label > input[type=checkbox]:focus-visible,
  label > input[type=radio]:focus-visible {
    outline: none;
  }

  @media (prefers-contrast: more) {
    :focus-visible {
      outline-width: 3px;
      outline-color: currentColor;
    }
  }

  @media (forced-colors: active) {
    :focus-visible {
      outline: 2px solid Highlight;
      outline-offset: 2px;
    }
  }
}
```

---

## Files changed

### CSS — additive

| File                                                          | Change                                                                                      |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `app/assets/stylesheets/css/variables.css`                    | Added 5 `--focus-outline-*` tokens. Removed `--box-shadow-focus`.                          |
| `app/assets/stylesheets/css/focus.css` *(new)*                | Global `:focus-visible` rule + fallbacks + label-wrap logic                                 |
| `app/assets/stylesheets/application.css`                      | Imported `focus.css`                                                                        |

### CSS — per-component cleanup

| File                                                          | Change                                                                                      |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `button.css`                                                  | Removed 2 `:focus-visible` blocks. Added `rounded-md` to `.button-icon`.                   |
| `sidebar.css`                                                 | Restored original focus-visible blocks (bg, z-index, color) but swapped `box-shadow` → inset `outline-offset`. Added `rounded-md` to `.sidebar-profile__action-trigger`. |
| `input.css`                                                   | Removed `:focus-visible` block                                                              |
| `tabs.css`                                                    | Removed custom ring on `:focus-visible`                                                     |
| `checkbox.css`                                                | Stripped `:focus-visible` from hover+focus combined selector                                |
| `radio.css`                                                   | Removed `::after` pseudo-ring. Added explicit `border-radius: 50%` + focus-visible reinforcement. Kept hover `outline-none` override. |
| `typography.css`                                              | Removed `a:focus-visible` custom outline. Added `rounded-xs` on anchor focus-visible.      |
| `badge.css`                                                   | Stripped `focus:outline-none focus:ring-*` from `@apply`                                    |
| `color_scheme_switcher.css`                                   | Stripped `focus:ring-*` from 3 `@apply` lines. Added inset-offset override for theme/accent options. |
| `search.css`                                                  | Removed `focus:ring-0` / `focus:ring-accent` on aa-Input                                    |
| `dropdown.css`                                                | Removed `focus:outline-none` from base. Swapped ring utilities → `outline-offset: var(--focus-outline-offset-inset)` |
| `fields/tags.css`                                             | Swapped `box-shadow: var(--box-shadow-focus)` → outline tokens                             |
| `file_upload_input.css`                                       | Swapped to outline. Upgraded `:focus-within` → `:has(:focus-visible)` so ring only shows on keyboard focus |
| `filters.css`                                                 | Added `rounded-md` to `.filters-date-input__action`                                         |

### ERB template fixes (F78 fixes)

| File                                                          | Change                                                                                      |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `_confirm_dialog.html.erb`                                    | Removed `focus:ring-4 focus:outline-hidden focus:ring-danger/30`, `focus:ring-tertiary focus:z-10` |
| `filters_component.html.erb`                                  | Removed `class: 'focus:outline-hidden'` — **F78 fix**                                       |
| `actions_component.html.erb`                                  | Removed `class: 'focus:outline-hidden'` — **F78 fix**                                       |
| `backtrace_alert_component.html.erb`                          | `focus:outline-hidden focus:text-gray-300` → `hover:text-gray-300 focus:text-gray-300`. Added `rounded-md`. Replaced inline SVG with `helpers.svg "tabler/outline/x"`. |
| `radio_field/edit_component.html.erb`                         | Sibling-label pattern → nested-label pattern (`<label>` now wraps input + text) so the wrap rule in `focus.css` can match |

### Preview expansion

| File                                                          | Change                                                                                      |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `focus_visible_audit_preview.rb`                              | Comment updated                                                                             |
| `focus_visible_audit_preview/default.html.erb`                | Rewrote intro + legend. Added 10+ rows: color-scheme switcher (button / theme / accent), `<details>`/`<summary>`, `[tabindex="0"]` div, `.button-icon` (alert close), checkbox with/without label, radio with/without label. Added **surface matrix** (button/input/link × primary/secondary/tertiary/blue-500 fill). Added **inset validation case**. Added **DevTools testing header**. |

### Dummy app — TEMP test trigger (revert before merge)

| File                                                          | Change                                                                                      |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `spec/dummy/app/models/project.rb`                            | Added `before_save` that raises when a project's name is `trigger-backtrace` — enables manual testing of the backtrace alert's close button focus ring. **Revert before merging the PR.** |

---

## Known issues — must address before finalizing

### Radio fields

| Issue                                                                                                                                                                                                                                                                                                                                               | Severity          | How to reproduce                                                                                                                       |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Focus ring invisible after mouse click → Tab away → Shift+Tab back to selected radio.** Pressing arrow keys after re-focus makes the ring appear on non-selected options. Browser `:focus-visible` heuristic treats the returned radio as "last focused via mouse" even though the return was keyboard-driven. Not a CSS problem — needs JS or accepting the browser behavior. | A11y (WCAG 2.4.7) | `/avo/resources/fish/{id}/edit` → click a Size radio → Tab → Shift+Tab                                                                 |
| **`display_as: :tabs` mode hides the input with `class: "hidden"` (`radio_field/edit_component.html.erb:7`).** Element becomes non-focusable entirely — keyboard users can't reach it. Pre-existing bug, not introduced by the refactor, but should be noted.                                                                                                   | A11y (WCAG 2.1.1) | Any resource with `field :x, as: :radio, display_as: :tabs`                                                                            |

### Checkbox fields

| Issue                                                                                                                                                                                                                 | Severity | How to reproduce                                                                                                                        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Checkbox rendering broken in the index table view** (per note — needs investigation). Likely unrelated to the focus refactor but blocking full verification.                                                        | Unknown  | Open any resource with boolean fields in the index table view (e.g. `/avo/resources/posts`)                                             |

### Sidebar — chevron & focus alignment

| Issue                                                                                                                                                                                                                                                                              | Severity | Location                                          |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------- |
| **Chevron icon not aligned with the focus ring.** On a focused sidebar group header, the expand/collapse chevron (controlled by `menu_controller.js` via `sidebar-icon--collapsed` class) sits flush against the right edge of the element. The inset focus ring appears to "crowd" the chevron. Related to `app/javascript/js/controllers/menu_controller.js` which toggles the class, and the sidebar layout. | Polish   | `/avo/resources/*` — sidebar group with chevron   |
| **Icon size on the group header looked oversized in one screenshot.** Base icon size is `size-4` (16px) on `.sidebar-icon` but the fingerprint icon in the screenshot appeared larger. Worth tracing the render path.                                                                                                                                                                                          | Polish   | Same area                                         |

### Final contrast gate (Topic 8)

Deferred. Before merge, run the sign-off checklist from the planning phase:

- [ ] Tab from first focusable to last in the audit preview — consistent ring on every element
- [ ] Mouse-click test — no ring on any element (handled by `:focus:not(:focus-visible)` reset)
- [ ] Toggle dark mode — ring visible on every surface
- [ ] DevTools contrast picker — ring ≥3:1 vs. adjacent on every surface in light and dark
- [ ] DevTools → Rendering → `forced-colors: active` → ring uses system `Highlight`
- [ ] DevTools → Rendering → `prefers-contrast: more` → ring widens to 3px + `currentColor`
- [ ] 200% zoom — ring still visible and proportionate
- [ ] axe DevTools run — no new violations
- [ ] `grep` for `outline: none` / `outline-hidden` — only the global reset remains
- [ ] `grep` for `--box-shadow-focus` — zero hits
- [ ] `grep` for `focus:ring-*` / `focus:outline-*` in ERBs — zero hits

If any surface fails contrast:

- Add a dark-mode override: `.dark { --focus-outline-color: var(--color-blue-300); }`
- Or adopt the Soueidan dual-color pattern as a per-surface override

---

## Testing guide

### Lookbook — isolated

```
bin/dev
→ /rails/lookbook/preview/focus_visible_audit/default
```

- Tab through all 47 rows from the first input to the last tabindex element
- Every element should show the same info-colored outline with 1px breathing offset
- Rows flagged `bg-warning/5` are historical pre-refactor markers (kept during PR for review)

### Live app — by area

| Area                       | Page / action                                                                                   | What to verify                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Sidebar                    | Any page — tab through sidebar sections, groups, links, subitems                                | Inset ring on all 5 focusable types. Active link keeps its bg. Profile `⋮` trigger has rounded ring |
| Top navbar                 | Color scheme switcher — theme/accent/light/dark buttons                                         | Keyboard ring on scheme buttons. Inset ring inside the theme/accent popover                        |
| Resource index             | `/avo/resources/{any}`                                                                          | Pagination per-page dropdown, row links, filters trigger, actions trigger                          |
| Resource edit form         | `/avo/resources/{any}/{id}/edit`                                                                | Input fields, textarea, select, date filter's `×` button (rounded), tagify wrapper                 |
| Radio field                | `/avo/resources/fish/{id}/edit`                                                                 | Ring wraps label + radio together. Ring circular on bare radio                                     |
| Boolean field              | Any resource with boolean field in edit view                                                    | Ring on the checkbox (label has no text so ring matches checkbox bounds)                           |
| Filters popover            | Filters button → open panel → tab through filters                                               | Filters trigger now shows keyboard ring (F78 fixed). Date filter `×` button rounded                 |
| Actions dropdown           | Resource with actions configured → "Actions" button                                             | Trigger shows keyboard ring (F78 fixed). Dropdown items use inset offset                           |
| Grid view                  | `/avo/resources/{any}?view_type=grid`                                                           | Per-card `⋮` dropdown items (inset ring)                                                           |
| Confirm dialog             | Delete any record (turbo confirm)                                                               | Confirm / Cancel buttons show keyboard ring (previously hidden)                                    |
| File upload                | Any resource with file field                                                                    | Tab into file input — ring on the whole drop-zone wrapper (only on keyboard, not mouse click)      |
| Backtrace alert            | Edit a Project, set name to `trigger-backtrace`, Save                                           | Red alert appears. Tab to `×` close — rounded ring. Hover — icon dims                              |

### DevTools checks

```
Cmd/Ctrl + Shift + P → "Show Rendering"
```

- **Emulate `prefers-color-scheme: dark`** — verify every surface stays readable
- **Emulate `forced-colors: active`** — ring becomes system `Highlight`
- **Emulate `prefers-contrast: more`** — ring widens to 3px + `currentColor`

---

## Revert list before merging

- `spec/dummy/app/models/project.rb` — remove the `before_save` test trigger (clearly commented `TEMP: focus-ring audit trigger`)
- Preview audit rows with `bg-warning/5` historical markers — decide whether to strip the "Focus CSS" column at final merge per Topic 6 decision 6

---

## Related files for future cleanup (noted, not acted on)

| Path                                                                                       | Reason                                                                                      |
| ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| `app/javascript/js/controllers/menu_controller.js`                                         | Sidebar chevron alignment with focus ring — see Known Issues                                 |
| `app/components/avo/fields/boolean_field/edit_component.html.erb`                          | Uses `sr-only peer` pattern for toggle variant; should verify focus behavior on toggle mode |
| `app/components/avo/fields/radio_field/edit_component.html.erb` (tabs mode, line 7)        | Hidden radio in `display_as: :tabs` mode — pre-existing a11y gap                            |

---

## Nuanced decisions worth preserving

Small calls that aren't self-evident from the code. Preserve these unless deliberately reconsidering.

| Decision                                                                                                                                                     | Why it was made                                                                                                                              | Don't accidentally revert by                                                      |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Anchor links use `rounded-xs` (2px) on `:focus-visible`, **not** `rounded-sm` (4px) or `rounded-md` (6px)                                                    | `rounded-lg` (matching buttons/inputs) looked bulky around inline text. User iterated to `rounded-xs` as tight enough to feel intentional without overshooting the text's cap height. | "Harmonizing" the anchor radius to match buttons/inputs                           |
| Sidebar uses **inset** offset (`-2px`), not outward                                                                                                          | Sidebar items are close-packed (`my-px` between links). Outward ring overlapped neighbors; required `z-10` hacks. Inset hugs the inside edge and never overlaps. Same rationale as `.dropdown-menu__item`. | Reverting sidebar to outward offset for "consistency" with the global default     |
| Color scheme switcher: **theme & accent options** use inset, **scheme buttons** (auto/light/dark) use outward                                                | Theme and accent options live inside a popover with `overflow: hidden`. Scheme buttons are standalone and don't clip.                        | Sweeping all `.color-scheme-switcher__*` into inset or outward                    |
| `.button-icon` got a base `rounded-md`                                                                                                                       | Only consumer is the alert close button (`alert_component.html.erb:29`). Had no radius before because the old `box-shadow` ring hung in space; the new `outline` needs a radius to look right. | Removing as "unused" — it IS used, just in only one place                         |
| Backtrace alert close button: kept both `focus:text-gray-300` AND `hover:text-gray-300`                                                                      | Original intent was "dim on interaction." Original code used `focus:` only. Adding `hover:` covers mouse hover which didn't previously trigger the dim.                    | Deleting `hover:` as "redundant"                                                  |
| Confirm dialog buttons: dropped `focus:z-10` when removing `focus:ring-*`                                                                                    | `focus:z-10` was needed because the old `box-shadow` ring could be clipped by siblings. With `outline` (which doesn't participate in stacking), it's dead.                     | Re-adding it thinking the ring needs stacking                                     |
| `.filters-date-input__action`: `rounded-md` added, no inset override                                                                                          | Sits inside the input's right padding (`!pe-9`), enough room for the outward 3px ring. If visual testing shows cramping, add `outline-offset: 0` or inset.                   | Preemptively making it inset before verifying                                     |
| Radio field edit template: nested-label pattern (`<label>` wraps input + text), not sibling `for=""` pattern                                                  | Nested pattern is the only way our `label:has(> input:focus-visible)` rule can match. Also gives a bigger click target.                     | Reverting to sibling pattern for "simplicity"                                     |
| `radio.css` hover rule (`input[type=radio]:hover { outline-none }`) preserved                                                                                 | Accidentally removed during Task 2 cleanup; restored after user flagged it. It's cancelling the combined `input[type=radio]:hover, input[type=checkbox]:hover` outline rule in `checkbox.css` — intentional per-element hover affordance. | Deleting as "no-op" when cleaning up                                              |
| Radio input uses explicit `border-radius: 50%`, not Tailwind's `rounded-full` (`calc(infinity * 1px)`)                                                        | Native radio with `appearance: auto` didn't reliably propagate the Tailwind value to the outline. Explicit 50% is more universally respected. | "Simplifying" back to `rounded-full`                                              |
| Preview rows `bg-warning/5` marker redefined as "historical pre-refactor flag" (not "inconsistent")                                                          | Every flagged row has been migrated. The marker stays during PR review so reviewer can see before/after. Strip post-merge per Topic 6 decision 6. | Treating the flag as an active warning                                            |

---

## Session testing log (what was visually verified)

These were checked during the implementation session and looked correct. **Not** a substitute for the contrast gate, just a record of what's been eyeballed.

| Area                                    | Verified                                                                                                   |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Tagify wrapper                          | Ring wraps entire tags container (screenshot confirmed)                                                    |
| Sidebar group header                    | Inset ring visible (screenshot confirmed)                                                                  |
| Sidebar profile `⋮` trigger             | Rounded `rounded-md` ring (fix verified)                                                                   |
| Filters date `×` button                 | Rounded ring (fix verified)                                                                                |
| Color scheme theme/accent options       | Inset ring — no more clipping on "Mauve" / "Olive" (screenshot confirmed)                                  |
| Backtrace alert `×` close               | Rounded ring + SVG swapped to `tabler/outline/x` (verified)                                                |
| Lookbook audit — row 15b/16b            | Label wrap ring on checkbox/radio nested in label (single ring, no double — layer fix verified)            |
| Lookbook audit — row 16a radio          | Circular ring on bare radio (after `border-radius: 50%` fix)                                               |

Not yet verified:

- Dark mode rendering of all rings
- Forced-colors / prefers-contrast emulation
- 200% zoom
- Checkbox in index table view (**flagged as possibly broken**)
- Grid card `⋮` dropdown items on a live resource
- Actions dropdown items
- File upload drop-zone keyboard focus
