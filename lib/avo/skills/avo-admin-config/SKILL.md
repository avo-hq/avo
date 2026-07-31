---
name: avo-admin-config
description: Configure Avo's app-wide admin settings in config/initializers/avo.rb via Avo.configure — app name, timezone/currency, per-page and index behavior, layout width, home redirect, open-in-editor links, and the other global knobs that don't belong to a single feature. Use when the user wants to change how many records per page, rename the admin / change the app name, set the timezone or currency for the admin, default the index to grid view, make the admin full-width, keep clicking a row from opening the record, skip the show view / go straight to edit, open Avo files in Cursor or VS Code from the UI, keep the sidebar always open, redirect the admin home to a dashboard, add a class to the body tag, make rows denser, widen the sidebar or turn off sidebar resizing, persist filters/pagination across requests, or opt out of usage metadata.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  avo-version: "4.0.24"
  requires-gem: none — Community
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Avo Admin Configuration

Avo's initializer, `config/initializers/avo.rb`, holds the **app-wide** settings that don't belong to any one feature — the app name, timezone, per-page count, index behavior, layout widths, the home redirect, the open-in-editor links, logging, and so on. They're all set inside a single `Avo.configure do |config|` block by assigning to `config.<name>`:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.app_name = "Avocadelicious"
  config.timezone = "UTC"
  config.currency = "USD"
  config.per_page = 24
end
```

A handful of these have **resource-level equivalents** — set them globally here, or override per resource as a class attribute (`self.default_view_type`, `self.pagination`, `self.density` on dashboard cards). With no configuration at all, Avo computes the app name from your Rails app, uses UTC/USD, shows 24 records per page in constrained-width tables, and redirects the logo to your first resource.

**This skill is partly a router.** It owns only the genuinely-global knobs. For anything that belongs to a specific feature, hand off to its skill instead of duplicating it here:

- Installing, mounting (`root_path`, `prefix_path`), and the license key → **avo-setup**
- Logos, favicons, colors, theming (`appearance`) → **avo-branding-appearance**
- Menus, global search, breadcrumbs, keyboard shortcuts (`main_menu`, `global_search`, `set_initial_breadcrumbs`, `hotkeys`) → **avo-navigation-search**
- Caching internals, cache store, N+1 tuning → **avo-performance**
- Authorization client and policy wiring → **avo-authorization**

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Customization guide (task-oriented, worked examples): https://docs.avohq.io/4.0/customization.md
- Customization API (per-option reference, types, defaults): https://docs.avohq.io/4.0/customization-api.md

## When this applies

**Explicit (Avo named):** "set `config.app_name`", "change `per_page` in the Avo initializer", "set `default_view_type` to `:grid`", "use `container_width = :full`", "set `resource_default_view = :edit`", "configure `default_editor_url`", "enable `persistence`", "set `body_classes`".

**Implicit (Rails-shaped, no mention of Avo):** "change how many records show per page in the admin", "rename the admin / change the app name in the top bar", "set the timezone/currency the admin displays", "default the admin list to grid/card view", "make the admin full-width", "clicking a row shouldn't open the record", "skip the show page and go straight to edit", "open the admin's source files in Cursor/VS Code from the UI", "keep the sidebar always open / hide the collapse button", "make the sidebar wider by default", "stop people resizing the sidebar", "send people to a dashboard when they open the admin", "add a CSS class to the `<body>` tag", "make the admin rows denser / tighter", "keep my filters and pagination when I navigate away", "stop the admin from phoning home usage stats".

## Common settings

Every option below is a `config.<name>` assignment inside `Avo.configure`. Most accept a literal value or a block/proc evaluated per request (useful for `I18n` lookups or per-user logic).

### Naming and locale

```ruby
config.app_name = "Avocadelicious"              # navbar label next to the logo
config.app_name = -> { I18n.t "app_name" }      # block form for dynamic/i18n names
config.timezone = "UTC"                          # for date/datetime fields
config.currency = "USD"                          # for currency fields
config.locale   = "en-US"                        # force Avo's UI locale (default: I18n.default_locale)
```

`app_name` defaults to the humanized Rails application class name. To replace the single app-name link with a list of navbar links, that's the **header menu** → **avo-navigation-search**.

### Index view behavior

```ruby
config.per_page = 24                             # default page size (default 24)
config.per_page_steps = [12, 24, 48, 72]         # options in the per-page picker
config.via_per_page = 8                          # page size inside has_many association tables
config.default_view_type = :grid                 # :table (default), :grid, :map, or a custom view type
config.first_sorting_option = :asc               # direction on first sort click (default :desc)
config.density = :tight                          # row height: :tight, :normal (default), :relaxed
config.field_wrapper_layout = :stacked           # label above value everywhere (default :inline)
config.click_row_to_view_record = false          # stop the whole row linking to Show (default true)
config.id_links_to_resource = true               # render id fields as links to the record (default false)
config.cache_resources_on_index_view = false     # disable per-row index caching (default true)
config.search_debounce = 300                     # ms to wait after typing before searching (default 300)
config.pagination = { type: :countless }         # global pagination defaults; same keys as self.pagination
```

`default_view_type`, `pagination`, and `density` (on dashboard cards) also exist as per-resource class attributes — set globally here, override per resource. Row-control placement (`resource_row_controls_config`) lives on the table-view docs.

### Layout

```ruby
config.container_width = :full                            # one width for all views
config.container_width = { index: :full, show: :small }   # or per view / group alias
config.sidebar = {                                        # the sidebar's three knobs, merged over the defaults
  toggle_visible: false,                                  # hide the collapse button → sidebar stays open on desktop (default true)
  resizable: false,                                       # remove the drag-to-resize handle (default true)
  default_width: 320                                      # px the sidebar starts at before a user drags it (default 256)
}
config.hide_layout_when_printing = true                   # drop sidebar/navbar/footer when printing
config.body_classes = "custom-theme compact-layout"       # add classes to <body>; also accepts an Array or a block
```

`config.sidebar` is a hash merged over `{toggle_visible: true, resizable: true, default_width: 256}`, so set only the keys you change. On desktop the sidebar edge is a drag handle: users resize it and the width persists **per browser** (a cookie, not a user preference). `default_width` sets the starting width and is clamped to `200`–`480` — an unparseable value falls back to `256` rather than clamping to the minimum. Both settings apply at `lg` (1024px) and wider only; below that the sidebar is a full-height overlay at the 256px default. A width the user has dragged to wins over `default_width`. The flat `config.sidebar_toggle_visible = false` still works and writes into `config.sidebar[:toggle_visible]`, but the hash is the canonical home.

`container_width` values are `:large` (default index), `:small` (default show/forms), and `:full`. The hash form accepts individual views (`:index`, `:show`, `:new`, `:edit`, `:create`, `:update`) and group aliases (`:forms`, `:display`, `:single`); a specific key wins over an alias. The `body_classes` block runs in Avo's `ExecutionContext`, so it has `current_user`, `request`, and `params`.

### Navigation home and record flow

```ruby
config.home_path = "/avo/dashboard"                       # where the logo / "/avo" redirects
config.home_path = -> { avo_dashboards.dashboard_path(:dashy) }   # block form has route helpers
config.resource_default_view = :edit                      # skip the Show view; go straight to Edit
config.alert_dismiss_time = 8000                          # ms before flash alerts auto-dismiss (default 5000)
```

Pair `home_path` with `set_initial_breadcrumbs` for a cohesive landing (breadcrumbs detail → **avo-navigation-search**). Setting `home_path` also hides the development-only "Get started" sidebar item.

### Editor and development

```ruby
config.default_editor_url = "vscode://file/%{path}"       # the </> "open in editor" links (dev only)
config.view_component_path = "app/frontend/components"     # where generated field view_components land
config.model_generator_hook = false                       # stop `rails g model` from also generating an Avo resource
```

In `development`, Avo renders a small `</>` icon next to resources, actions, filters, dashboards, cards, and forms; clicking it opens that class's source file via `default_editor_url`, where `%{path}` is the absolute file path. It **defaults to Cursor** (`cursor://file/%{path}`) — switch the scheme for VS Code (`vscode://file/%{path}`), Sublime (`subl://open?url=file://%{path}`), etc.

### Other global knobs

```ruby
config.set_context do                                     # attach a payload to the global `context` object
  { params: request.params }
end

config.persistence = { driver: :session }                # keep association pagination + static filters across requests

config.associations = {                                   # global association defaults (set only what you change)
  lookup_list_limit: 1000,
  frames: { loading: :lazy, auto_load_for: 15.minutes }
}

config.turbo = -> { { instant_click: true } }             # Turbo behavior inside Avo
config.default_url_options = [:account_id]                # params appended to every generated path (route multitenancy)
config.logger = -> { ActiveSupport::Logger.new(Rails.root.join("log", "avo.log")) }
config.exclude_from_status = ["license_key", "ip"]        # items hidden on /avo_private/status (license_key hidden by default)
config.send_metadata = false                              # opt out of usage metadata (Community licenses only)
```

## Gotchas

- **`container_width` replaces the Avo-3 booleans.** `config.full_width_container = true` → `config.container_width = :full`; `config.full_width_index_view = true` → `config.container_width = { index: :full }`; `full_width_container = false` → just remove the line. It raises `ArgumentError` on an unknown width or hash key.
- **`resource_default_view` replaces `skip_show_view`.** The old `config.skip_show_view = true` is now `config.resource_default_view = :edit` (default `:show`). This retargets row links, post-create/update redirects, and association links to Edit.
- **`persistence: { driver: :session }` can overflow the cookie store.** Rails' default cookie session store is capped at 4096 bytes; many stored pagination + filter states raise `ActionDispatch::Cookies::CookieOverflow`. Move to a scalable session store (Redis, Memcache) before enabling it broadly.
- **`default_editor_url` defaults to Cursor.** If a user's `</>` icons open Cursor unexpectedly, that's the default — point it at their editor. The icons only render in `development`.
- **Disable `cache_resources_on_index_view` when fields vary by role.** The index cache key uses the record's `id`/`created_at` and the resource file md5 — **not the current user** — so a resource that shows/hides fields per role (`visibility:`) will serve one user's row layout to another. Turn it off there. For the caching model and cache store, see **avo-performance**; for role-based field visibility, see **avo-authorization**.
- **Sidebar resizing is a drag-only gesture.** It doesn't satisfy [WCAG 2.2 SC 2.5.7 (Dragging Movements)](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html), so an app working to an AA conformance claim or a VPAT should set `config.sidebar = {resizable: false}`. Related: sidebar labels now truncate with an ellipsis (plus a hover tooltip) instead of wrapping — if a menu relied on long labels wrapping, shorten them or widen the sidebar.
- **`click_row_to_view_record` is JS-enhanced.** Making a `<tr>` behave as a link isn't native HTML; Avo does it with JavaScript, which can have side effects. Disabling it (`false`) reserves navigation for the explicit row controls.
- **Verify before writing.** Option names and defaults drift between versions and several were renamed in Avo 4 — check the docs URLs above or the app's installed `lib/avo/configuration.rb` rather than trusting memory.

## Report

When done, tell the user:

- The exact `config.<name>` lines you added or changed in `config/initializers/avo.rb`, and what each does.
- Any Avo-3 → Avo-4 rename you applied (`container_width`, `resource_default_view`) and the old line it replaced.
- Follow-ups the change implies: a server restart to reload the initializer; a scalable session store if you enabled `persistence`; disabling `cache_resources_on_index_view` if they gate fields by role.
- When a setting has a per-resource equivalent (`default_view_type`, `pagination`, `density`), note it so they know they can override it on individual resources.
- Redirect anything out of scope to the right skill: install/mount/license → **avo-setup**, appearance/theming → **avo-branding-appearance**, menus/search/breadcrumbs/shortcuts → **avo-navigation-search**, caching depth → **avo-performance**, authorization → **avo-authorization**.
