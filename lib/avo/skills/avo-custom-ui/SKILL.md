---
name: avo-custom-ui
description: >-
  Build custom UI inside an Avo admin panel and the JS/CSS/Tailwind plumbing behind it —
  standalone custom-tool pages (route + controller + sidebar item), resource tools embedded in a
  record's Show/Edit view, Avo's native ViewComponents (a_button/a_link, ui.panel, ui.card,
  ui.description_list), ejecting Avo's own partials and components, Stimulus controllers, dynamic
  and dependent forms, custom CSS/JS through the asset pipeline, the TailwindCSS integration, and
  packaging any of it as an Avo plugin. Use when the user wants a custom admin page, a dashboard
  widget or panel on a record page, extra form inputs that aren't columns, a nested form,
  cascading or dependent selects, a field toggled by another field, their own JavaScript or
  Stimulus controller in the admin, to override how a view renders, to style a custom tool to
  match the admin, or to package a customization as a reusable plugin.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  avo-version: "4.0.24"
  requires-gem: none — Community
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Avo Custom UI

Everything about building **your own UI inside an Avo admin** and the asset plumbing behind it: standalone pages, embedded record widgets, Avo's reusable components, ejecting Avo's markup, Stimulus/dynamic forms, custom CSS/JS, the Tailwind integration, and packaging it all as a plugin.

Two things to fix before writing any code:

- **Which surface?** A **standalone page** (own route + sidebar item) is a [custom tool](#custom-tools). A widget **on an existing record's Show/Edit** is a [resource tool](#resource-tools). Rendering Avo's *existing* markup differently is an [eject](#eject-views). A *new field type* is a different skill (see Gotchas).
- **Everything here is Community.** Custom tools, resource tools, ejecting, JS/Stimulus, and the Tailwind integration need no paid gem.

**Docs** — fetch on demand with WebFetch; prefer the raw `.md` (clean, no HTML). Read the page before implementing anything non-trivial in that area.

- Docs map (find any other page): https://docs.avohq.io/4.0/docs-map.md
- Custom tools (standalone pages): https://docs.avohq.io/4.0/custom-tools.md
- Resource tools (embedded partials + custom form inputs): https://docs.avohq.io/4.0/resource-tools.md
- Eject views: https://docs.avohq.io/4.0/eject-views.md
- Native components — button: https://docs.avohq.io/4.0/native-components/avo-button-component.md · panel: https://docs.avohq.io/4.0/native-components/avo-panel-component.md · card: https://docs.avohq.io/4.0/native-components/avo-card-component.md
- JavaScript & Stimulus: https://docs.avohq.io/4.0/javascript.md
- Asset handling: https://docs.avohq.io/4.0/asset-handling.md
- TailwindCSS integration: https://docs.avohq.io/4.0/tailwindcss-integration.md · Tailwind 4 migration: https://docs.avohq.io/4.0/tailwind-4-migration.md
- Plugins: https://docs.avohq.io/4.0/plugins.md · Asset manager: https://docs.avohq.io/4.0/asset-manager.md · Custom view types: https://docs.avohq.io/4.0/custom-view-types.md

## When this applies

| Request (Avo-shaped or plain Rails/product) | Section |
| --- | --- |
| "Add a custom page/section to the admin", "a dashboard page", "a reports screen with its own sidebar link" | [Custom tools](#custom-tools) |
| "Embed a custom panel/widget on the record page", "show related stats on the post's Show view" | [Resource tools](#resource-tools) |
| "Add extra inputs to the edit form that aren't columns", "build a nested form", "write a Hash/array attribute from the form" | [Resource tools → custom form inputs](#custom-form-inputs-and-nested-forms) |
| "Style my custom tool like the rest of Avo", "buttons/cards that match the admin", "dark-mode-ready markup" | [Native components](#native-components) |
| "Override how Avo renders the index table", "change a view's markup", "customize the sidebar/layout partial" | [Eject views](#eject-views) |
| "Add my own JS/CSS to the admin", "add a Stimulus controller to a resource" | [JavaScript & Stimulus](#javascript--stimulus) + [Assets & Tailwind](#assets--tailwind) |
| "When country changes reload cities", "cascading/dependent selects", "make the form dynamic" | [dependent selects](#dependent-selects-cascading-dropdowns) |
| "Toggle/disable a field based on another field" | [pre-made toggle/disable](#pre-made-toggledisable-no-js) |
| "Use Tailwind classes in custom admin UI", "my utility classes don't apply", "migrate the admin to Tailwind 4" | [Assets & Tailwind](#assets--tailwind) |
| "Package this as a reusable plugin/gem", "register a new view type / field / menu item from a gem" | [Advanced: package as a plugin](#advanced-package-as-a-plugin) |

Related skills: re-skinning colors/spacing through CSS variables is **avo-branding-appearance**; defining a brand-new field *type* is **avo-custom-fields**; enabling a registered custom index view type on a resource is **avo-index-views**.

## Custom tools

A **standalone page** — its own route, controller action, sidebar item — rendered inside Avo's layout. Reach for it for dashboards, reports, admin utility screens.

### Generate

```bash
bin/rails generate avo:tool dashboard
```

Creates (and restarts the server so the route takes effect):

- `app/views/avo/sidebar/items/_dashboard.html.erb` — the sidebar link (all files in this dir load into the sidebar, alphabetically — rename to reorder)
- `app/controllers/avo/tools_controller.rb` — a `ToolsController` on first run, with the action inserted
- `app/views/avo/tools/dashboard.html.erb` — the page view
- a route injected **inside your `mount_avo` block** in `config/routes.rb`

### Controller + route

```ruby
# app/controllers/avo/tools_controller.rb
class Avo::ToolsController < Avo::ApplicationController
  def dashboard
    @page_title = "Dashboard"          # rendered via the meta-tags gem
    add_breadcrumb title: "Dashboard"
  end
end
```

```ruby
# config/routes.rb — injected inside mount_avo, so it inherits Avo's auth
authenticate :user, ->(user) { user.is_admin? } do
  mount_avo do
    get "dashboard", to: "tools#dashboard", as: :dashboard
  end
end
```

Because the action inherits from `Avo::ApplicationController`, the view runs with the **full Avo view context**: `ui.*` components, `@page_title` and any instance var you set, `_current_user`, `Avo::Current.context`, `params`, and the `avo.` / `main_app.` path helpers. Set instance variables in the action, read them in the view — normal Rails.

### View

Build the page from Avo's own components so it matches the admin and gets dark mode for free:

```erb
<%# app/views/avo/tools/dashboard.html.erb %>
<div class="flex flex-col">
  <%= render ui.panel(title: "Dashboard") do |panel| %>
    <% panel.with_controls do %>
      <%= a_link("/admin", icon: "tabler/outline/external-link", style: :primary, color: :primary) do %>
        Admin
      <% end %>
    <% end %>

    <% panel.with_card(title: "New tool", padded: true) do %>
      <div class="flex flex-col justify-between min-h-24 space-y-4">
        <h3>What a nice new tool 👋</h3>
      </div>
    <% end %>
  <% end %>
</div>
```

### Use your app's helpers / path helpers

```ruby
class Avo::ToolsController < Avo::ApplicationController
  helper HomeHelper                     # make your helpers available in the view

  def dashboard
    @page_title = "Dashboard"
  end
end
```

Inside the engine, prefix path helpers: `avo.resources_posts_path(1)` for Avo routes, `main_app.posts_path` for your app's routes. Load your own CSS/JS via [Assets & Tailwind](#assets--tailwind).

## Resource tools

A **partial embedded inside a resource's Show/Edit view** — a widget bound to one record. Default-visible on `Show`.

### Generate + register

```bash
bin/rails generate avo:resource_tool post_info
```

Creates the config class `app/avo/resource_tools/post_info.rb` and the partial `app/views/avo/resource_tools/_post_info.html.erb`. Register it in the resource's `fields` block (it's placed like a field):

```ruby
# app/avo/resources/post.rb
class Avo::Resources::Post < Avo::BaseResource
  def fields
    tool Avo::ResourceTools::PostInfo, show_on: :edit   # or :forms, or default (Show)
  end
end
```

Control placement with the usual field visibility options (`show_on`, `only_on`, `show_on: :forms`).

### Partial context

The partial has access to: `tool` (your `PostInfo` instance), `@resource` (with `.record`, `.view`, `.params`), `form` (**only on New/Edit — check `form.present?`**), `params`, `Avo::Current.context`, and `current_user`.

### Keep logic out of the view

Define `post_initialize` on the tool — Avo calls it after hydration (no `super`, no overriding `initialize`). Inside it you have `resource`, `parent`, and `view`. Expose data via readers/methods and read them through `tool` in the partial:

```ruby
class Avo::ResourceTools::PostInfo < Avo::BaseResourceTool
  self.name = "Post info"
  # self.partial = "avo/resource_tools/post_info"   # override the partial path if needed

  attr_reader :foo

  def post_initialize
    @foo = :bar
  end

  def custom_method_call = :called
end
```

```erb
<%= tool.foo %>
<%= tool.custom_method_call %>
```

### Custom form inputs and nested forms

A resource tool is the way to add inputs to a form that aren't backed by columns — including nested (`fields_for`) inputs producing arrays/Hashes. **Three steps, all required:**

1. Render the inputs against `form` in the partial (show it only on forms):

```ruby
# app/avo/resources/fish.rb
class Avo::Resources::Fish < Avo::BaseResource
  self.extra_params = [:fish_type, properties: [], information: [:name, :history]]  # step 2

  def fields
    tool Avo::ResourceTools::FishInformation, show_on: :forms
  end
end
```

```erb
<%# app/views/avo/resource_tools/_fish_information.html.erb %>
<%= render ui.panel(title: @resource.record.name) do |panel| %>
  <% panel.with_card(padded: true) do %>
    <% if form.present? %>
      <%= form.label :fish_type %>
      <%= form.text_field :fish_type, class: input_classes %>

      <%= form.label :properties %>
      <%= form.text_field :properties, multiple: true, class: input_classes %>  <%# array %>

      <% form.fields_for :information do |information_form| %>
        <%= information_form.text_field :name, class: input_classes %>          <%# Hash %>
        <%= information_form.text_field :history, class: input_classes %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

2. **Permit the params** on the resource via `self.extra_params` (Avo runs `model.assign_attributes params.permit(extra_params)`). Anything not listed here silently never reaches the model.
3. **Make the model respond** to those attributes (real columns, or setters like `def fish_type=(v)`).

## Native components

Use Avo's own ViewComponents instead of hand-rolled `<div>`s — they keep custom UI visually consistent and **dark-mode-ready for free**. All are reachable in any Avo view context (custom tools, resource tools, ejected partials).

- **`a_button` / `a_link`** → `Avo::ButtonComponent`. `a_button` renders a `<button>`, `a_link` an `<a>` (first arg = href). Options: `style:` (`:primary`/`:outline`/`:text`, default `:outline`), `size:` (`:xs`/`:sm`/`:md`/`:lg`), `color:` (`:primary`, `:accent`, or any Tailwind color), `icon:` / `end_icon:` (icon path), `rounded: :full` (pill). Extra kwargs pass through to `link_to`/`button_to` — `method:`, `data:`, `title:`.

```erb
<%= a_link("/posts/1", method: :delete, data: { turbo_confirm: "Sure?" }) { "Delete" } %>
<%= a_button(style: :primary, icon: "tabler/outline/plus") { "New" } %>
```

- **`ui.panel(...)`** → `Avo::UI::PanelComponent`. A titled container with slots: `with_controls` (right-aligned header buttons), `with_card` (bordered card body), `with_body` (flush body, no card), plus `with_cover`, `with_sidebar`, `with_pre_body`, `with_footer`, `with_header`. Options: `title:`, `description:`, `class:`, `data:`.

- **`ui.card(...)`** → `Avo::UI::CardComponent`. A standalone bordered surface (the same card `panel.with_card` wraps). Options: `title:`, `description:`, `padded:`, `class:` (modifiers: `card--padded`, `card--compact-wrapper`, `card--compact-header-y`, `card--compact-header-x` — header compaction is split per axis, so compose the last two for both). Slots: `with_header`, `with_body`, `with_footer`.

- **`ui.description_list`** → wrap a **list of fields** so they render full-width with dividers, exactly like Avo's own field lists.

**Prefer built-in options over utility classes.** `padded: true` gives the card body Avo's exact standard padding — reach for it instead of adding your own `px-*`/`py-*`. `title:` / `description:` build the header for you. Inside a `ui.panel`, use its `with_card` slot rather than nesting a `ui.card` yourself. The card body ships **unpadded** by default (so tables/scrollers sit flush) — opt into `padded: true` for free-form content like forms and prose.

## Eject views

Avo renders from partials, ViewComponents, and controllers inside the gem. When config isn't enough, **copy one into your app and edit it** — your copy takes precedence.

```bash
# A gem partial → same path in your app
bin/rails generate avo:eject --partial app/views/layouts/avo/application.html.erb

# A prepared-template shorthand (ejects to app/views/avo/partials/)
bin/rails generate avo:eject --partial :logo
bin/rails generate avo:eject --partial :head        # inside <head>, after Avo's assets — style overrides
bin/rails generate avo:eject --partial :pre_head    # inside <head>, before Avo's assets
bin/rails generate avo:eject --partial :sidebar_extra

# A ViewComponent (copies both .rb and .html.erb)
bin/rails generate avo:eject --component Avo::Index::TableRowComponent

# All of a field's components, or just one view
bin/rails generate avo:eject --field-components text
bin/rails generate avo:eject --field-components text --view edit

# A controller (most commonly the application_controller extension layer)
bin/rails generate avo:eject --controller application_controller
```

Prepared-template symbols: `:logo`, `:header`, `:pre_head`, `:head`, `:scripts`, `:sidebar_extra`, `:profile_menu_extra`, plus the override files `:avo_overrides_css`, `:avo_overrides_js`, `:asset_overrides`.

**Scope to avoid replacing a component everywhere.** By default an ejected `Avo::Views` / `Avo::Fields` component replaces the original across the whole app. Add `--scope` to nest your copy in its own namespace, then wire it in only where wanted via `self.components` (resource) or the `components:` field option:

```bash
bin/rails generate avo:eject --component Avo::Views::ResourceIndexComponent --scope admins
# → app/components/avo/views/admins/resource_index_component.rb
#   class Avo::Views::Admins::ResourceIndexComponent < Avo::ResourceComponent
```

## JavaScript & Stimulus

Avo integrates a light Stimulus layer so you can make forms dynamic. First, add your JS entrypoint through the [asset pipeline](#assets--tailwind) — nothing loads otherwise.

### Attach controllers + use Avo's targets

```ruby
class Avo::Resources::Course < Avo::BaseResource
  self.stimulus_controllers = "course-resource select-field"   # space-separated
end
```

Avo also adds a default `resource-edit` / `resource-show` / `resource-index` controller per view, and passes each controller a `view` value (`index`/`show`/`edit`/`new`) in the DOM. For every field it emits ready-made Stimulus targets you can hook into:

- **Wrapper:** `data-[controller]-target="[fieldName][FieldType]Wrapper"` → `nameTextWrapperTarget`
- **Input** (Edit/New): `[fieldName][FieldType]Input` → `nameTextInputTarget`

Attach actions/classes/data to a field's input or wrapper via the `html:` option (see the field-options-api docs) to trigger your controller methods.

### Pre-made toggle/disable (no JS)

Show/hide or enable/disable one field from another with zero custom JS, using the built-in `resource-edit` controller:

```ruby
field :has_country, as: :boolean, html: {
  edit: { input: { data: {
    action: "input->resource-edit#toggle",                  # or #disable
    resource_edit_toggle_target_param: "countrySelectWrapper"
    # resource_edit_toggle_targets_param: ["aWrapper", "bWrapper"]   # multiple
  } } }
}
field :country, as: :select, options: { ... }
```

`#toggle` hides/shows the target; `#disable` greys it out; `#debugOnInput` logs events to the console for targeting checks. Target a `...Wrapper` when the field has multiple inputs (e.g. polymorphic `belongs_to`).

### Dependent selects (cascading dropdowns)

The canonical "change country → repopulate cities" flow. Wire an `input->` action + targets on the two selects, add an Avo engine route + controller action that returns JSON, and register a custom Stimulus controller that fetches and repopulates on `connect` and on change:

```ruby
# app/avo/resources/course.rb
self.stimulus_controllers = "course-resource"
field :country, as: :select, options: {...}, html: { edit: { input: { data: {
  course_resource_target: "countryFieldInput",
  action: "input->course-resource#onCountryChange"
} } } }
field :city, as: :select, options: {...}, html: { edit: { input: { data: {
  course_resource_target: "cityFieldInput"
} } } }
```

```ruby
# config/routes.rb — inside the Avo engine
Avo::Engine.routes.draw do
  scope :resources do
    get "courses/cities", to: "courses#cities"
  end
end

# app/controllers/avo/courses_controller.rb
class Avo::CoursesController < Avo::ResourcesController
  def cities = render json: Course.cities[params[:country].to_sym] || []
end
```

The Stimulus controller `fetch`es `${window.Avo.configuration.root_path}/resources/courses/cities?country=...` and rebuilds the city `<option>`s. Fetch the JavaScript doc for the full controller — it captures the initial value, guards to `edit`/`new` via `viewValue`, and shows a loading overlay.

### Register a custom controller

In your entrypoint, hook Avo's Stimulus instance and register your controller:

```js
// app/javascript/avo.custom.js
import SampleController from "controllers/sample_controller";
window.Stimulus.register("sample", SampleController);
```

```erb
<div data-controller="sample"><!-- ... --></div>
```

## Assets & Tailwind

### Load your own CSS/JS

Avo hooks into your app's existing pipeline — Importmap, esbuild/jsbundling, Propshaft, and Sprockets are all fully supported. The generator does the wiring:

```bash
bin/rails generate avo:js:install                    # Importmap: creates app/javascript/avo.custom.js,
                                                      # ejects _head.html.erb to load it, pins it in importmap.rb
bin/rails generate avo:js:install --bundler esbuild   # jsbundling/esbuild entrypoint instead
```

Manual (Sprockets/Propshaft): eject `:pre_head`, create `avo.custom.js` + `avo.custom.css`, and load them (`javascript_include_tag "avo.custom", defer: true` — always `defer: true` so order matches Avo's).

**Load order in `<head>` (later wins the cascade):** `_pre_head` (yours) → Avo's own CSS/JS → `avo-overrides.css` / `avo-overrides.js` → `_head` (yours) → brand-palette overrides. Put styles in `_pre_head` to let Avo's defaults load after them; use `_head` when you deliberately want to win.

### Tailwind integration

When Avo detects **`tailwindcss-ruby`**, it auto-enables the Tailwind integration and compiles an app-level stylesheet (`app/assets/builds/avo/application.css`) that includes Avo core + plugin styles, your styles from `app/assets/stylesheets/avo/**/*.css`, and any utility classes discovered under `app/`. This is what makes Tailwind classes you write in custom tools / ejected components / custom fields actually exist. Zero config to start:

```ruby
# Gemfile
gem "tailwindcss-ruby"
```

Add custom Avo styles under `app/assets/stylesheets/avo/` (they're built into the same stylesheet):

```css
/* app/assets/stylesheets/avo/buttons.css */
@layer components { .avo-btn-highlight { @apply px-3 py-2 rounded-md bg-indigo-600 text-white; } }
```

Run it with a watcher during dev (`bin/rails avo:tailwindcss:watch` in `Procfile.dev`). Extra scan roots via `config.tailwindcss_content_sources` (defaults to `Rails.root.join("app")`). Opt out with `config.tailwindcss_integration_enabled = false`.

### Quick no-build tweaks: `avo-overrides.css` / `avo-overrides.js`

Two files Avo loads on every screen, served **as-is** (not run through the Tailwind build). Because `avo-overrides.css` loads after Avo's stylesheet, overriding Avo's **CSS variables** here re-skins the whole admin with no build step (that's the **avo-branding-appearance** territory). Eject to customize: `rails g avo:eject --partial :avo_overrides_css` (or `:avo_overrides_js`, or `:asset_overrides` for both).

### Tailwind 4 migration

Avo's build emits Tailwind **v4** syntax. If you have your own Tailwind pipeline, migrate it to v4 and apply the breaking changes (renamed utilities like `rounded`→`rounded-sm`, explicit border colors since the default is now `currentColor`) to **every** custom field, resource tool, custom tool, custom card, and ejected component. Fetch the migration doc before touching a project that has an existing Tailwind config.

## Advanced: package as a plugin

Wrap any of the above into a Rails Engine so it's reusable across apps. Register everything from the **`avo_boot`** hook so it runs once on boot; `avo_init` runs on every request.

```ruby
# lib/avo/feed_view/engine.rb
initializer "avo-feed-view.init" do
  ActiveSupport.on_load(:avo_boot) do
    Avo.plugin_manager.register :feed_view
    Avo.plugin_manager.mount_engine Avo::FeedView::Engine, at: "/feed_view"

    # Extend Avo's classes
    Avo::Resources::Base.include Avo::FeedView::Concerns::FeedViewConcern

    # Inject assets into Avo's layout <head>
    Avo.asset_manager.add_javascript "/feed-view-assets/feed_view"
    Avo.asset_manager.add_stylesheet "/feed-view-assets/feed_view"
    Avo.asset_manager.register_stimulus_controller "feed", FeedController
  end
end
```

`Avo.plugin_manager` API:

- `register(name, priority: 10)` — add to the plugin list (lower priority runs earlier).
- `register_view_type(name, component:, icon:, active_icon:)` — a new index view type. **Pass `component:` as a string** (`"MyPlugin::ViewTypes::TimelineViewTypeComponent"`) to dodge boot load-order issues; the component inherits `Avo::ViewTypes::BaseViewTypeComponent` and must render `paginator_component`. Enabling it on a resource is **avo-index-views** (`self.view_types` / `self.default_view_type`).
- `register_field(method_name, klass)` — ship a field *type* from a gem (the plugin-author side of **avo-custom-fields**).
- `register_menu_item(name, &block)` — a custom menu DSL method for `config.main_menu`. Delegates to `avo-menu`; **no-op when avo-menu isn't installed**, so register unconditionally.
- `mount_engine(klass, at:)` — mount the engine's routes inside Avo.
- `installed?(name)` — adapt to what else is present.

Assets from library code go through `Avo.asset_manager` (not the app pipeline); Avo injects them but does **not** compile them — ship compiled builds, e.g. served from `app/assets/builds` via a `Rack::Static` middleware.

## Gotchas

- **Custom tool vs. resource tool vs. new field.** Standalone page → custom tool. Widget on a record's Show/Edit → resource tool. A new *input type* used across resources → **avo-custom-fields** (not this).
- **Ejected files are frozen copies — you own them forever.** They stop receiving upstream updates; Avo bug/security fixes won't reach your copy. Prefer CSS-variable / Tailwind-layer overrides and `--scope` (so you don't replace a component everywhere) before ejecting whole components.
- **The no-`mount_avo` fallback route is NOT behind auth.** A custom-tool route inside `mount_avo` inherits Avo's authentication. But if `config/routes.rb` has no `mount_avo` at all, the generator appends a standalone `Avo::Engine.routes.draw` block that is **unprotected** — secure it yourself.
- **Resource-tool custom inputs need all three steps.** Missing `self.extra_params` (params not permitted) or a model that doesn't respond to the attribute → the value silently never persists. Nested keys not listed in `extra_params` are dropped too.
- **`form` is only present on New/Edit.** Guard resource-tool partials with `if form.present?` or they blow up on Show.
- **Prefer components over hand-rolled divs.** `ui.panel` / `ui.card` with `padded:` / `title:` give you Avo's spacing, headers, and dark mode; utility classes on bare `<div>`s drift out of sync and miss dark mode.
- **`avo-overrides.js` runs once, but Avo navigates with Turbo.** One-shot DOM edits vanish on the next visit — use a Stimulus controller (re-connects each visit) or a `turbo:load` listener.
- **`avo-overrides.css` is served as-is — NOT compiled by Tailwind.** `@apply` and utility classes won't be generated there; it's for raw CSS and CSS-variable overrides. Put Tailwind-using CSS under `app/assets/stylesheets/avo/`.
- **Tailwind integration silently stays off** unless `tailwindcss-ruby` is present, and — if you pull Tailwind via `tailwindcss-rails` — that gem is **>= 4.0** (on 3.x the integration is disabled even though `tailwindcss-ruby` is there). Symptom: your utility classes don't exist in the admin.
- **New JS/CSS not loading?** You skipped the asset-pipeline entrypoint. Run `avo:js:install` (or wire `avo.custom.js` manually) — `self.stimulus_controllers` alone loads nothing.
- **Plugin registration must be inside `ActiveSupport.on_load(:avo_boot)`**, `register_view_type`'s `component:` should be a **string**, and `register_menu_item` is a no-op without `avo-menu`.

## Report

When done, tell the user:

- Which surface you built (custom tool / resource tool / ejected view / plugin) and the exact files created or edited (absolute paths), including the resource(s) you registered a tool on.
- Which components/patterns it uses (`ui.panel`/`ui.card`, `a_button`/`a_link`, pre-made toggle/disable, dependent-select controller, ejected + `--scope`).
- For form inputs: that you added `self.extra_params` and whether the model already responds to those attributes (or the setters the user still needs to add).
- Asset/Tailwind wiring done vs. left to the user: the `avo:js:install` entrypoint, `tailwindcss-ruby` (and `tailwindcss-rails >= 4.0`), the watcher process.
- Any follow-ups they must do: secure a fallback (non-`mount_avo`) route, maintain ejected copies on upgrades, permit missing params, or compile/serve plugin assets.
