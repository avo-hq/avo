---
name: avo-index-views
description: Control how records render on an Avo resource's Index screen — table styling, grid cards, map markers, and which view types are available. Use when the user wants to change how a list of records looks or behaves on the index. Avo phrasings ("enable grid view", "set default_view_type", "configure row_options", "add a map view", "restrict view_types") and Rails-shaped ones without naming Avo ("show these products as image cards", "put the stores on a map", "highlight failed orders in red", "gray out archived rows", "let users toggle between list and grid", "make grid the default", "add a data attribute / Stimulus controller to each row", "move the row action buttons to the left", "run an action on all matching records not just this page"). Not for authoring brand-new custom view types (that's plugin work — see avo-custom-ui).
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Index Views

Everything here configures the **Index** screen of an Avo resource — the page that lists all records. You change it by setting **class attributes on the resource file** at `app/avo/resources/<model>.rb`, e.g. `class Avo::Resources::Product < Avo::BaseResource`. A few settings (global row-control defaults, the app-wide default view type) live in `config/initializers/avo.rb` inside `Avo.configure do |config|`.

Avo ships three built-in index view types: **table** (default), **grid**, and **map**. A resource can offer several and let users switch between them; the current pick is persisted in the URL as `?view_type=`.

**Docs** (fetch on demand — read the page before implementing that piece). Start from the docs map `https://docs.avohq.io/4.0/docs-map.md`, then:
- Overview + choosing/restricting view types: `https://docs.avohq.io/4.0/views.md`
- Table styling: `https://docs.avohq.io/4.0/table-view.md`, API `https://docs.avohq.io/4.0/table-view-api.md`
- Grid cards: `https://docs.avohq.io/4.0/grid-view.md`
- Map markers: `https://docs.avohq.io/4.0/map-view.md`
- Select-all across pages: `https://docs.avohq.io/4.0/select-all.md`
- Custom view types (plugin authoring, out of scope here): `https://docs.avohq.io/4.0/custom-view-types.md`

Published under `https://docs.avohq.io/4.0/<page>.html`. Fetch with WebFetch if the local checkout isn't present.

## When this applies

Use this skill when the request is about the **appearance or behavior of the index list**, not the fields on it. Signals:

- "Show X as cards / a gallery / a grid" → **grid view**.
- "Put X on a map", geospatial data, latitude/longitude, stores/cities/locations → **map view**.
- "Highlight / color / gray out / dim rows", per-row `class`/`data`/`title`, "add a Stimulus controller to each row" → **table `row_options`**.
- "Move the action buttons", "controls are hidden behind columns", "reveal buttons on hover" → **row controls placement**.
- "Let users switch between list and grid", "make grid/map the default", "only allow the table view" → **view types**.
- "Run an action on every matching record, not just this page" → **select-all** (cross-links to `avo-actions`).

**Not this skill:** inventing a brand-new view type (timeline, calendar, kanban) is plugin authoring — a ViewComponent inheriting `Avo::ViewTypes::BaseViewTypeComponent` registered from an engine. Mention it briefly and point to the **avo-custom-ui** skill and `https://docs.avohq.io/4.0/custom-view-types.md`. This skill only *enables and configures* built-in (or already-registered) view types.

**License:** everything here is Community — no paid add-on required.

## Workflow

1. **Find the resource file.** Glob `app/avo/resources/*.rb` (and `**/*.rb` for namespaced ones). The class is `Avo::Resources::<Model>`. If the user named a model, match it; otherwise ask or infer from context.
2. **Identify which knob.** Map the request to one of the sections below (table / grid / map / view types / select-all).
3. **Read the resource** before editing so you preserve `def fields`, existing class attributes, and `self.includes`.
4. **Read the relevant doc page** (see Docs above) to confirm option names and defaults before writing DSL — the surface is small but exact.
5. **Apply the change** as a class attribute near the top of the class body (after `self.title` / `self.includes` if present, before `def fields`).
6. **Keep `view_types` and `default_view_type` in sync** whenever you add a view — see Gotchas.
7. **Report** what you changed and any follow-ups (gems, env vars, Tailwind classes, preloading).

## View types

### Choosing which view types are available

Two independent attributes:

- `self.default_view_type` — which view opens first. Defaults to `:table`. Also settable app-wide via `config.default_view_type` in the initializer.
- `self.view_types` — which views appear in the switcher (restricts the set). When only one is available, the switcher is hidden.

Adding `grid_view` or `map_view` config automatically adds that type to the switcher — you only need `view_types` to **restrict** or **reorder**.

```ruby
# app/avo/resources/city.rb
class Avo::Resources::City < Avo::BaseResource
  self.default_view_type = :grid          # opens in grid
  self.view_types = [:table, :grid]       # switcher order follows this array
end
```

Restrict to a single view (no switcher shown):

```ruby
self.view_types = :table
```

Decide per request with a block — has `current_user`, `params`, `record`, `resource` via `Avo::ExecutionContext`:

```ruby
self.view_types = -> do
  current_user.admin? ? [:table, :grid] : :table
end
```

`default_view_type` accepts a block too. "Make grid the default for everything" → set `config.default_view_type = :grid` in the initializer instead of per-resource.

### Table view

Default; needs no config. Two independent customizations: **row controls** (where the show/edit/delete/action buttons sit) and **`row_options`** (HTML attributes on each `<tr>`).

**Row controls** — move or float the per-row buttons. Per resource:

```ruby
class Avo::Resources::User < Avo::BaseResource
  self.row_controls_config = {
    placement: :left,       # :right (default), :left, or :both
    float: true,            # sticky to the row end with a gradient fade
    show_on_hover: true     # hidden until the row is hovered
  }
end
```

Global default for all resources goes in the initializer:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.resource_row_controls_config = { placement: :left, float: true, show_on_hover: true }
end
```

`row_controls_config` merges over the global config, so set only the keys you change. `float` and `show_on_hover` are designed for `placement: :right`; other placements are allowed but may look off.

**`row_options`** — declaratively set `<tr>` attributes per record. This is how you highlight/gray-out/tag rows or attach a Stimulus controller, without overriding the row component.

```ruby
# app/avo/resources/order.rb
class Avo::Resources::Order < Avo::BaseResource
  self.includes = [:customer]           # preload anything the blocks touch
  self.table_view = {
    row_options: {
      class: -> {
        case record.status
        when "failed"  then "bg-red-50 dark:bg-red-950/30"
        when "shipped" then "bg-emerald-50 dark:bg-emerald-950/30"
        else ""
        end
      },
      data: { controller: "highlightable", test_id: -> { "order-#{record.id}" } },
      title: -> { "Order ##{record.id} — #{record.status}" }
    }
  }
end
```

Each value is static or a `-> {}` block (the whole hash can also be one block). Blocks run **once per row, per render** through `Avo::ExecutionContext` with `record`, `resource`, `view` (`:index` on the main index, `:has_many` inside an association panel), plus `current_user`, `params`, view helpers. The same config also applies to `has_many` association tables listing this resource. Return `nil`/`false` to omit an attribute.

Supported keys:
- `class` — String, Symbol, Array, or `{ "cls" => bool }` hash (like Rails' `class_names`). Appended after Avo's classes, so they win at equal specificity.
- `data` — hash of `data-*`, deep-merged with Avo's; `data-controller`/`data-action` are token-concatenated (yours added alongside Avo's, never replacing).
- `style` — inline CSS string.
- Other passthrough HTML attributes (`title`, `aria-label`, …).

Common recipes:
- **Gray out archived rows:** `class: -> { "opacity-60 italic" if record.archived? }`
- **Colored left border by priority:** `style: -> { "border-left: 4px solid #{record.priority_color};" }`
- **Theme-aware background via Avo's tokens:** `style: "background-color: var(--color-secondary);"`

### Grid view

Card layout for image-heavy resources. Enable by setting `self.grid_view` with a `card` block returning `cover_url`, `title`, `body`, and optional `badge`. The `card` block runs once per record through `Avo::ExecutionContext`.

```ruby
# app/avo/resources/product.rb
class Avo::Resources::Product < Avo::BaseResource
  self.default_view_type = :grid    # optional: open in grid
  self.grid_view = {
    card: -> do
      {
        cover_url: record.image.attached? ? main_app.url_for(record.image.variant(resize_to_fill: [300, 300])) : nil,
        title: record.title,
        body: simple_format(record.description),
        badge: {
          label: record.new? ? "New" : "Updated",
          color: record.new? ? "green" : "orange",   # base or semantic color; unknown → neutral
          style: record.new? ? "solid" : "subtle",   # subtle (default) | solid
          title: "Availability",                       # tooltip
          icon: "tabler/outline/trending-up"
        }
      }
    end
  }
end
```

- `cover_url` — String; `nil` falls back to a placeholder image.
- `title` — String.
- `body` — String; HTML-safe strings render as HTML (use `simple_format`, `truncate`, etc.).
- `badge` — optional hash: `label`, `color` (base colors like `red`/`blue`/`emerald`, or semantic `success`/`danger`/`warning`/`info`/`neutral`), `style` (`subtle`/`solid`), `title` (tooltip), `icon` (path like `"tabler/outline/…"` or `"heroicons/outline/…"`). Skipped entirely when both `label` and `icon` are blank.

Restyle card wrappers with an `html:` block keyed by section → view → `wrapper` → `classes`:

```ruby
self.grid_view = {
  card: -> { { cover_url: ..., title: record.name, body: record.excerpt } },
  html: -> do
    {
      title: { index: { wrapper: { classes: "bg-blue-50 dark:bg-blue-900 rounded-md p-2" } } },
      cover: { index: { wrapper: { classes: "rounded-lg overflow-hidden" } } }
    }
  end
}
```

Grid has **no per-card HTML-attribute API** — `row_options` is table-only. `html:` styles the card sections, not the card container.

### Map view

Plot records with geospatial data on a map. Enable with `self.map_view`.

```ruby
# app/avo/resources/city.rb
class Avo::Resources::City < Avo::BaseResource
  self.map_view = {
    mapkick_options: { controls: true },
    record_marker: -> {
      {
        latitude: record.coordinates.first,
        longitude: record.coordinates.last,
        tooltip: record.name
      }
    },
    map: { position: :left },      # :left | :right | :top | :bottom — table takes the other side
    table: { visible: true }       # show the index table alongside the map
  }
end
```

Options:
- `mapkick_options` — forwarded to the [mapkick gem](https://github.com/ankane/mapkick). Avo sets a default `style` and always controls `height` (any `height` you pass is overwritten).
- `record_marker` — Proc evaluated per record; must return a hash with `latitude` and `longitude` (optionally `tooltip`, `label`, `color`). Markers missing lat/long are skipped. Default reads `record.coordinates.first`/`.last`. Use this block to source coordinates from anywhere (API, cache), not just the DB.
- `map` — `{ position: … }` places the map; the table takes the remaining side (`:left`/`:right` side-by-side, `:top`/`:bottom` stacked).
- `table` — `{ visible: true|false }`; default renders no adjacent table.
- `extra_markers` — Proc returning an array of marker hashes for points not backed by records.

**Requirements** (report these): add the **`mapkick-rb`** gem (NOT `mapkick`) to the `Gemfile`. That is all — Avo defaults the map to [OpenFreeMap](https://openfreemap.org), which needs no account, no API key and has no request cap. Set a valid `MAPBOX_ACCESS_TOKEN` from a [Mapbox](https://account.mapbox.com/auth/signup/) account only if you want Mapbox styles; Avo then defaults to those instead. Pin a provider with `config.map_view = {styles: :open_free_map}` (or `:mapbox`), or give `styles` a `{light:, dark:}` pair of style URLs.

Make it the default with `self.default_view_type = :map`.

### Select all across pages

Not a view type — a table affordance. Checking the header "Select all" checkbox and confirming "select all matching" lets an action run on **every record the current query matches**, across all pages, not just the visible page. Avo serializes (and encrypts) the whole query — filters, sorting, scopes — and reconstructs it inside the action.

It works out of the box on the table view; nothing to enable on the resource. The action itself is where the selection is consumed — cross-link the **avo-actions** skill for writing/handling the action. If serialization fails, Avo silently disables select-all rather than crashing (see the `normalizes` gotcha below).

## Gotchas

- **`view_types` / `default_view_type` must stay in sync with what's registered.** Requesting a view type not in the available list raises an error; rendering one that was never configured raises `Avo::ViewTypeComponentNotFoundError`. If you set `default_view_type = :grid`, make sure grid is actually configured (or in `view_types`).
- **`row_options` values must be `String`/`Symbol`/`Integer`** (or `nil`/`false` to omit). A raw boolean like `record.archived?` raises `ArgumentError` — call `.to_s`: `data: { archived: -> { record.archived?.to_s } }`. `class:` additionally accepts Array and the `{class => bool}` hash form.
- **Denied `<tr>` attributes** (raise `ArgumentError`, or in production fall back to defaults + log): `id`, `role`, `aria-selected`, any `on*` handler (`onclick`, …), `tabindex`, `contenteditable`, `draggable`. Use `data: { action: "..." }` (Stimulus) instead of `on*`. Reserved `data-*` keys Avo owns (silently ignored): `index`, `component_name`, `resource_name`, `record_id`, `resource_id`, `visit_path`, `reorder_target`.
- **Custom Tailwind classes need the compiler to see them.** With Avo's [Tailwind CSS integration](https://docs.avohq.io/4.0/tailwindcss-integration.md), classes written **literally** inside blocks are scanned from `app/avo` and compiled. **Dynamically-built class names** (`"role-#{record.slug}"`, string concatenation) are invisible — register them with Tailwind v4's `@source inline(...)` in an Avo stylesheet. Without the integration (precompiled bundle only), no new utilities are generated at all — only classes already in Avo's bundle work.
- **`row_options` blocks run per row, per render.** Preload every association they touch via `self.includes`, or you get an N+1 across every row. Keep blocks cheap.
- **Dark mode is your responsibility** for user classes — pair `dark:` variants (`bg-blue-50 dark:bg-blue-950/40`) or use Avo's semantic CSS variables via `style:`. For custom backgrounds, use semitransparent values or explicit `hover:` variants so Avo's row hover/selection overlay still shows through.
- **Map markers need `latitude` + `longitude`.** Records whose `record_marker` returns a hash missing either are silently dropped from the map.
- **Select-all serialization can break on a model `normalizes` proc.** `normalizes :status, with: ->(s) { s }` combined with a filter on that attribute raises `TypeError: no _dump_data is defined for class Proc`, which auto-disables select-all. For apps created before Rails 7.1, set `config.active_record.marshalling_format_version = 7.1` in `config/application.rb`.
- **Authoring a brand-new custom view type is out of scope.** Timeline/calendar/kanban views are plugin work (ViewComponent + engine registration). Point the user to the **avo-custom-ui** skill and `https://docs.avohq.io/4.0/custom-view-types.md`; here only enable built-in/registered types.

## Report

Tell the user:
- Which resource file(s) and attribute(s) you changed (`self.table_view`, `self.grid_view`, `self.map_view`, `self.view_types`, `self.default_view_type`, `self.row_controls_config`, or the initializer).
- Any external requirements: the `mapkick-rb` gem for maps (`MAPBOX_ACCESS_TOKEN` only if they want Mapbox styles rather than Avo's keyless OpenFreeMap default); the Tailwind integration and/or `@source inline(...)` for custom/dynamic classes; `self.includes` additions to avoid N+1.
- If you set a `default_view_type`, confirm the matching view is configured/available so the switcher stays consistent.
- For select-all or custom-view-type requests, note the cross-linked skill (**avo-actions**, **avo-custom-ui**) that carries the rest of the work.
