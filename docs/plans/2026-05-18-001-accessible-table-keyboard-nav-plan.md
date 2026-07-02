# Accessible Table Keyboard Navigation

## Problem

On resource index pages, ↑/↓ arrow keys cycle through table rows **globally** — the controller listens on `document` and intercepts arrow keys whenever the user isn't typing in a field. This:

- Blocks normal page scrolling for keyboard users
- Doesn't follow the WAI-ARIA grid pattern
- Has no visible focus indicator on the table itself, so screen reader / sighted keyboard users have no way to know what's "active"

## Goal

Make arrow-key row navigation **opt-in via focus** while preserving a fast path for power users. Follow WAI-ARIA Authoring Practices for grids.

## Behavior contract

### Three ways to enter "navigating rows" mode

| Path             | Trigger                            | Result                                                                       |
| ---------------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| **Tab**          | Tab key lands on the table         | Table itself gains focus (visible ring). ↑/↓ now work. No row selected yet — first ↓ selects row 1. |
| **Shift+T**      | Global shortcut from anywhere      | Programmatically focuses the table. Same state as Tab-in (no row pre-selected). |
| **j / k**        | Global shortcut from anywhere      | Focuses the table AND immediately moves to row 1 (or next/prev if already on a row). For power users. |

### Exit / clear

| Key       | When row focused                    | When only table focused          |
| --------- | ----------------------------------- | -------------------------------- |
| `Escape`  | Clear row focus, keep table focused | Blur table, fall back to body    |
| `Tab`     | Move to next focusable element after the table |                                  |

### While in the table

| Key       | Action                                                              |
| --------- | ------------------------------------------------------------------- |
| ↑ / ↓     | Move row focus (only when `document.activeElement` is inside the table) |
| `Enter`   | Visit focused row's detail page (existing behavior)                 |
| `Space`   | Toggle row's checkbox (existing behavior)                           |
| row hotkeys | Continue working on the focused row only (existing behavior)      |

### What gets removed

- Document-level interception of ↑/↓/Enter/Space/Escape when the table isn't focused

## Implementation

### 1. Table markup — `app/components/avo/view_types/table_component.html.erb:47`

Add `tabindex`, `role`, and target binding:

```erb
<table
  class="w-full border-separate border-spacing-0"
  tabindex="0"
  role="grid"
  aria-label="<%= @resource.plural_name %>"
  data-index-row-navigator-target="table">
```

### 2. Row markup — `app/components/avo/index/table_row_component.html.erb`

Give each `<tr>` a stable `id` so `aria-activedescendant` can reference it. Use the existing record identifier:

```erb
id="row-<%= @resource.class.to_s.parameterize %>-<%= @resource.record.to_param %>"
```

(Confirm the helper method available in the component; may need to add a private `row_dom_id` method.)

### 3. Controller — `app/javascript/js/controllers/index_row_navigator_controller.js`

Concrete changes:

- **Add** `static targets = ['table']`
- **Gate arrow/Enter/Space/Escape handling** on `this.tableTarget.contains(document.activeElement)`. Outside the table, those keys go to the browser (scroll, etc.)
- **Add** global `j` / `k` listener (with the existing `TYPING_SELECTOR` guard):
  - Focus the table if it isn't focused
  - Then run the existing ↓ / ↑ logic
- **Add** global `Shift+T` listener (also gated by typing guard):
  - Focus the table
  - Do **not** move to a row — user presses ↓ next
- **Sync `aria-activedescendant`** on the table whenever `currentIndex` changes — set to the focused row's `id`, remove on clear
- **Listen for `blur`** on the table — call `clearFocus()` so the row indicator goes away when the user Tabs out
- **Listen for `focus`** on the table — no-op for state, but ensures the visible ring shows up via `:focus-visible`

### 4. Global hotkeys — `app/javascript/js/global_hotkeys.js`

Add `Shift+T` and `j` / `k` to `DIRECT_HOTKEYS`. Each handler dispatches a custom event the controller listens for, OR dispatches to the table directly. Preferred: keep the logic inside the controller and have `global_hotkeys.js` dispatch a `CustomEvent` like `avo:focus-resource-table` on `document` — the controller handles it. Keeps concerns separated.

### 5. Visual focus indicator

Two pieces:

- **Table-level focus** (when user has Tabbed in / pressed Shift+T): use `:focus-visible` on `<table>` — add a CSS rule in `app/assets/stylesheets/css/table.css` using the existing accent ring color. Browser's default outline is acceptable as a fallback.
- **Row-level focus** (when arrows have selected a row): reuse the existing `.table-row.is-keyboard-focused` rule (`app/assets/stylesheets/css/table.css:62`) — **no change needed**.

### 6. Help modal

Add three entries to the shortcut help modal (find via `persistent-modal` references): Shift+T, j, k. Also document that ↑/↓ work after the table is focused.

### 7. Tests

- Capybara/Cuprite spec: load an index page, press ↓ at body level → assert nothing changes (no row focused, body scroll not blocked)
- Press `Shift+T` → assert table has focus
- Press ↓ → assert row 1 is keyboard-focused and `aria-activedescendant` matches its id
- Press `j` from body → assert table focused AND row 1 focused
- Press `Escape` while row focused → assert row cleared, table still focused
- Press `Escape` again → assert table blurred

## Out of scope (intentionally)

- **Roving tabindex within rows** (making row controls non-tab-stops, navigating them with arrows inside a row). That's a bigger refactor of the grid pattern and not required for the accessibility win here.
- **Grid-cell navigation** (←/→ between cells). Same reason — bigger pattern, current rows aren't designed for it.
- **Config flag** to disable. The new behavior is strictly more accessible; no opt-out needed.

## Open questions

- The plural name for `aria-label` — confirm the resource has a `plural_name` accessor; otherwise use `@resource.class.name.demodulize.pluralize.titleize` or similar.
- Does the resource search input live in the natural Tab order *before* the table? Verify Tab sequence: filters → view toggle → search → table.
- Currently the controller is conditionally attached when `@reflection.blank?` (only on top-level index, not has-many tables). Confirm this still holds for the new behavior — `Shift+T` and `j`/`k` should be no-ops on association tables.

## Files touched

- `app/components/avo/view_types/table_component.html.erb` — table attrs
- `app/components/avo/index/table_row_component.html.erb` — row `id`
- `app/javascript/js/controllers/index_row_navigator_controller.js` — gating + new entry paths
- `app/javascript/js/global_hotkeys.js` — Shift+T / j / k registration
- `app/assets/stylesheets/css/table.css` — `:focus-visible` on table
- Help modal partial (TBD path) — shortcut listing
- Spec file (new or existing index navigation spec)
