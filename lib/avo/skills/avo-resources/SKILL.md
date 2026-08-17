---
name: avo-resources
description: Generate an Avo CRUD resource from a Rails model and configure resource-level behavior in `app/avo/resources/<name>.rb` plus its controller. Use when the user wants to generate an Avo resource, add a model to the admin panel, expose a table in the admin, set a resource's title/description/icon/cover/avatar or discreet info, fix ActionDispatch::MissingController, avoid N+1 with includes, tune sort/pagination/index query, build an array (non-DB) resource, or map multiple resources to one model.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Resources

An Avo **resource** turns one Rails model into a full CRUD admin interface — index, show, new, edit, delete — configured from a single Ruby file at `app/avo/resources/<name>.rb`. Think of it as the admin-side counterpart to the model: the model defines the data, the resource defines how Avo displays and manages it. Every resource is a class like `Avo::Resources::Post < Avo::BaseResource`, and **each resource must be paired with a controller** at `app/controllers/avo/<name>s_controller.rb` (e.g. `Avo::PostsController < Avo::ResourcesController`). The generator creates both for you. Resource-level options are class attributes (`self.title`, `self.includes`, …) declared at the top of the file; the fields themselves go in `def fields`, and associations are just fields too — those two are documented in the sibling **avo-fields** and **avo-associations** skills, not here.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Resources guide: https://docs.avohq.io/4.0/resources.md — API reference: https://docs.avohq.io/4.0/resources-api.md
- Cover & avatar: https://docs.avohq.io/4.0/cover-and-avatar.md
- Discreet information: https://docs.avohq.io/4.0/discreet-information.md
- Array resource: https://docs.avohq.io/4.0/array-resource.md
- Custom errors / validation display: https://docs.avohq.io/4.0/custom-errors.md

## When this applies

**Explicit (Avo named):** "generate/create an Avo resource", "add a resource for `Order`", "configure the `Post` resource", "set the resource title/description/icon", "add a cover photo / avatar to the resource", "make an array resource", "register two resources for one model", "STI resource".

**Implicit (Rails-shaped, no mention of Avo):** "add the `Invoice` model to the admin", "expose the `orders` table in the admin panel", "show these records in Avo but they don't come from a table", "the admin is showing the wrong resource for `User`", "I get `ActionDispatch::MissingController` when I open a resource", "the index is doing N+1 queries", "sort the admin list by `position`", "let admins look up records by slug instead of id", "the admin count query is too slow on a huge table".

## Workflow

### 1. Generate the resource (and its controller)

For an existing model, generate the resource directly. **This also auto-generates the paired controller** — the resource generator invokes `avo:controller` for you:

```bash
bin/rails generate avo:resource post
```

That writes `app/avo/resources/post.rb` and `app/controllers/avo/posts_controller.rb`. If the model already has columns and associations, matching `field` lines are filled in automatically.

Other generation modes:

```bash
# One resource + controller for every ActiveRecord model in the app
bin/rails generate avo:resource --model-class post   # secondary resource on the Post model → sets self.model_class = "Post"
bin/rails generate avo:all_resources                 # scans app/models, skips abstract/PORO/form objects
bin/rails generate avo:resource Galaxy::Planet       # namespaced → app/avo/resources/galaxy/planet.rb + Avo::Galaxy::PlanetsController
bin/rails generate avo:resource Movie --array        # in-memory (non-AR) resource, see step 6
```

When you scaffold the model itself, the Avo resource **and** controller are generated alongside the standard Rails files:

```bash
bin/rails generate model car make:string mileage:integer          # also creates Avo::Resources::Car + Avo::CarsController
bin/rails generate model car make:string mileage:integer --skip-avo-resource  # opt out
```

**MissingController gotcha:** every resource needs its controller. If the controller file is missing (deleted, or the resource was hand-written), opening the resource raises `ActionDispatch::MissingController`. Generate the missing one:

```bash
bin/rails generate avo:controller post
```

To make generated controllers inherit from a shared base (e.g. one that adds authentication), pass `--parent-controller` on either generator, or set it once in the initializer:

```bash
bin/rails g avo:resource city --parent-controller Avo::BaseResourcesController
```

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.resource_parent_controller = "Avo::BaseResourcesController" # default: "Avo::ResourcesController"
end
```

### 2. Fill in fields and associations

The generated file has a `def fields` block. Adding, ordering, and configuring fields — and association fields like `belongs_to`/`has_many` — is the job of the **avo-fields** and **avo-associations** skills. Don't re-derive that here; a minimal resource looks like:

```ruby
# app/avo/resources/post.rb
class Avo::Resources::Post < Avo::BaseResource
  self.includes = []

  def fields
    field :id, as: :id
    field :name, as: :text
    field :body, as: :textarea
    field :user, as: :belongs_to   # ← see avo-associations
  end
end
```

### 3. Set the record's display identity

Avo guesses a record's display name from `name`, `title`, then `label`, falling back to `id`. Override with `self.title` (a Symbol pointing at an attribute/getter, or a block with `record`/`resource`):

```ruby
class Avo::Resources::Comment < Avo::BaseResource
  self.title = :slug
  # or a computed block:
  self.title = -> { ActionView::Base.full_sanitizer.sanitize(record.body).truncate(30) }
end
```

Add a message under the resource name with `self.description`, the sidebar icon with `self.icon`, a tint for that icon with `self.color`, and an image with `self.avatar` (small, on show/forms) or `self.cover` (banner):

```ruby
class Avo::Resources::User < Avo::BaseResource
  self.description = "These are the users of the app."
  self.icon = "tabler/outline/user"
  self.color = :purple
  self.avatar = { source: :avatar, visible_on: [:show, :forms] }
  self.cover  = { source: :cover_photo, size: :md, visible_on: [:show] }
end
```

- `self.description` is rendered as **raw HTML** — never feed it user-editable data (stored-XSS risk). A block gets `record`, `resource`, `view`, `current_user`, `params`.
- `self.color` (Symbol or String, default `nil`) tints **only the icon stroke** — the label and the hover/active backgrounds stay neutral, so give related resources the same color to group them visually. One of `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`, `teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`, `fuchsia`, `pink`, `rose`; an unknown name falls back to the neutral icon, and the colors adapt to light and dark themes on their own. It follows the resource past the sidebar: the initials chip in the breadcrumbs is tinted too, and with `avo-advanced_search` installed so are the resource group headers in global search. A `color:` on the menu entry (**avo-menu**) overrides it.
- `self.cover`/`self.avatar` were named `cover_photo`/`profile_photo` in Avo 3. A **Symbol** `source:` renders nothing for unpersisted (new) records — use a block if you want a placeholder on `new`/`index`.

Surface small metadata (timestamps, id, a badge/link) next to the title without spending a field, via `self.discreet_information`:

```ruby
class Avo::Resources::Post < Avo::BaseResource
  self.discreet_information = [
    :timestamps,
    { as: :badge, text: -> { record.published_at ? "Published" : "Draft" } }
  ]
end
```

### 4. Tune index performance and behavior

Eager-load associations and attachments to kill N+1 on the index:

```ruby
class Avo::Resources::Post < Avo::BaseResource
  self.includes = [:user, :tags]        # associations, Index view
  self.attachments = [:cover_photo]     # Active Storage attachments, Index view
  # self.single_includes / self.single_attachments do the same on Show/Edit only
end
```

Control the default sort, drop a model `default_scope` on index, or teach Avo to find records by something other than `id`:

```ruby
class Avo::Resources::Task < Avo::BaseResource
  self.default_sort_column = :position
  self.default_sort_direction = :asc            # :asc | :desc (default :desc)
  self.index_query = -> { query.unscoped }      # receives `query`, returns modified query
end

class Avo::Resources::Post < Avo::BaseResource
  # For slug/custom to_param lookups. `id` is an Array in batch contexts (bulk actions) → return a collection there.
  self.find_record_method = -> {
    id.to_i == 0 ? query.find_by!(slug: id) : query.find(id)
  }
end
```

FriendlyId is detected automatically (no `find_record_method` needed); prefixed_ids and hashid-rails work out of the box. On huge tables, skip the count with `self.pagination = { type: :countless }`.

### 5. Control the save flow and error display

```ruby
class Avo::Resources::Comment < Avo::BaseResource
  self.confirm_on_save = true          # ask before persisting
  self.after_create_path = :index      # :show (default) | :edit | :index
  self.after_update_path = :edit
  # self.devise_password_optional = true  # Devise: allow updating a user without a password
end
```

Validation and errors need **no Avo config** — Avo runs your model's validations on every write. Anything you add via `errors.add` stops the action and shows the message:

- `errors.add(:age, "must be over 18.")` → inline under the `age` field.
- `errors.add(:base, "…")` (or an error whose attribute has no field on the form) → alert banner at the top.
- Non-validation exceptions during save/destroy (FK constraint on delete, `after_save` failure) are caught, added as a `:base` alert, and shown gracefully instead of 500-ing. Developers additionally see the backtrace (gated on `Avo::Current.user_is_developer?`).

### 6. Array (non-database) resources

For structured data that isn't backed by a table, generate with `--array`. The class extends `Avo::Resources::ArrayResource` and returns data from `records` (array of hashes, AR objects, an `ActiveRecord::Relation`, or `StoreModel` instances):

```ruby
# app/avo/resources/movie.rb
class Avo::Resources::Movie < Avo::Resources::ArrayResource
  def records
    [
      { id: 1, name: "The Shawshank Redemption", release_date: "1994-09-23" },
      { id: 2, name: "The Godfather", release_date: "1972-03-24" }
    ]
  end

  def fields
    field :id, as: :id
    field :name, as: :text
    field :release_date, as: :date
  end
end
```

Array resources are **Beta**: sorting is not supported, and the array is rebuilt on every request (cache inside `records` if it gets heavy). For external-API-backed data, prefer an [HTTP Resource](https://docs.avohq.io/4.0/http-resource.md).

### 7. Sidebar, shortcuts, external links, and multiple resources per model

```ruby
class Avo::Resources::TeamMembership < Avo::BaseResource
  self.visible_on_sidebar = false      # hide from the auto-generated menu (not the menu editor)
  self.hotkey = "g m"                  # keyboard shortcut to the Index view
  self.external_link = -> { main_app.team_membership_path(record) }  # button to a public page
end
```

When **two resources map to the same model**, Avo picks one alphabetically wherever it needs a default (associations, links) — often the wrong one. Pin the default with `model_resource_mapping`, and point specific associations elsewhere with `use_resource` (an avo-associations concern):

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.model_resource_mapping = { "User": "Avo::Resources::User" }
end
```

For STI, send index clicks to the child record with `self.link_to_child_resource = true` on the parent resource; set `self.model_class` on any resource whose model can't be inferred from the class name.

## Key options

| Option | Does | Tiny example |
| --- | --- | --- |
| `self.title` | Record display name | `self.title = :name` |
| `self.description` | Message under the name (raw HTML!) | `self.description = "App users."` |
| `self.icon` | Sidebar icon | `self.icon = "tabler/outline/user"` |
| `self.color` | Tint for that icon (stroke only) | `self.color = :purple` |
| `self.avatar` / `self.cover` | Small photo / banner | `self.cover = { source: :cover_photo, size: :md }` |
| `self.discreet_information` | Metadata by the title | `self.discreet_information = :timestamps` |
| `self.model_class` | Model when not inferable / secondary resource | `self.model_class = "Delayed::Job"` |
| `self.includes` / `self.attachments` | Eager-load on Index (N+1) | `self.includes = [:user, :tags]` |
| `self.default_sort_column` / `_direction` | Index sort | `self.default_sort_column = :position` |
| `self.index_query` | Base Index query (drop default_scope) | `self.index_query = -> { query.unscoped }` |
| `self.find_record_method` | Lookup by slug/custom id | `-> { query.find_by!(slug: id) }` |
| `self.pagination` | Skip count on big tables | `self.pagination = { type: :countless }` |
| `self.confirm_on_save` | Confirm dialog before save | `self.confirm_on_save = true` |
| `self.after_create_path` / `_update_path` | Post-save redirect | `self.after_create_path = :index` |
| `self.visible_on_sidebar` / `self.hotkey` | Menu presence / shortcut | `self.visible_on_sidebar = false` |
| `self.external_link` | Button to a public URL | `-> { main_app.post_path(record) }` |
| `self.link_to_child_resource` | STI: jump to child on click | `self.link_to_child_resource = true` |
| `config.buttons_on_form_footers` | Save/Back in form footer (initializer, global) | `config.buttons_on_form_footers = true` |

Search (`self.search`), grid/map view types, record reordering, and i18n live on their own docs pages — reach for the docs map when a request touches those.

## Gotchas

- **Every resource needs a controller.** A missing controller → `ActionDispatch::MissingController` on open. Generate it with `bin/rails g avo:controller <name>`. The resource generator does this automatically; hand-written resources don't.
- **`self.description` is raw HTML.** Never interpolate user-editable content into it — stored XSS. Same care with `title:` in discreet-information tooltips (sanitize HTML there).
- **Cover/avatar renamed in Avo 4.** It's `self.cover` / `self.avatar` now, not `cover_photo` / `profile_photo`. A Symbol `source:` shows nothing for unpersisted records — use a block for a placeholder.
- **Two resources, one model → wrong one wins.** Avo resolves the default alphabetically. Set `config.model_resource_mapping` and/or `use_resource:` on associations.
- **Secondary / namespaced / oddly-named resources need `self.model_class`** (or the matching namespace) or Avo can't infer the model. Namespaced resources whose namespace matches the model's namespace infer automatically.
- **Array resources are Beta:** no sorting, and `records` re-runs every request. Cache inside `records` for large sets, or move to an HTTP Resource.
- **`find_record_method` in batch contexts:** `id` arrives as an Array for bulk actions — return a collection (`query.where(...)`) in that branch, not a single record.
- **`visible_on_sidebar` only affects the auto-generated menu.** If the app uses the menu editor, control visibility in its `visible` block instead.
- **Don't re-invent fields/associations here.** Field DSL is the avo-fields skill; `belongs_to`/`has_many`/`use_resource` is avo-associations.
- **Verify before writing.** Option names drift between versions — check the docs URLs above or the app's installed Avo source rather than trusting memory.

## Report

When done, tell the user:

- Which resource file(s) and controller file(s) you created or edited (full paths), and the generator command(s) run.
- The model each resource maps to, and any `self.model_class` / `model_resource_mapping` you set to disambiguate.
- The resource-level options you configured (title, includes, sort, pagination, etc.) and why.
- Anything still needed for the resource to work: run pending migrations, generate a missing controller, define fields (avo-fields) or associations (avo-associations), or add a policy if authorization is enabled.
- Note when a resource is an array/Beta resource or has multiple resources per model, so the user knows the limitations.
