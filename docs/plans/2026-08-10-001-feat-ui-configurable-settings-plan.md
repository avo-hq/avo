---
title: "feat: UI-configurable settings framework"
type: feat
status: draft
date: 2026-08-10
---

# feat: UI-configurable settings framework

## Overview

Today every Avo option is a code option. `self.default_view_type = :grid` means
editing a file, opening a PR, and deploying — to change which layout a screen
opens in. The same is true of `per_page`, of a kanban board's default swimlane,
of a calendar's default period. All of them are values a person looking at the
screen could reasonably decide for themselves.

This plan adds one framework that lets **avo core and any Avo gem mark an option
as editable in the UI**, declared next to where the option already lives, and
resolved per app / per tenant / per user at read time. The declaration is one
line. Everything else — storage, resolution, the settings screens, the reset
affordance, authorization — is provided.

The design goal is that adding a new configurable option is a **one-line
change in the gem that owns it**, with no work in core, no new screen, and no
new controller. If a gem has to write UI to make its option configurable, the
framework has failed.

---

## Decisions locked

| Question | Decision |
| --- | --- |
| Where values live | Avo-owned table, shipped migration |
| Where a setting is declared | Inline, next to the option it configures |
| UI surfaces | Global settings screen, per-resource tab, in-context control, per-user profile — all four |
| Which gem ships it | Entirely in avo core |
| Resolution | `user → tenant → app → code default`, first hit wins; `scopes:` decides which layers are editable |
| Authorization | `Avo.configuration.is_admin_method`, overridable by block, per-key override |
| Scopes | `app` and `user`, plus `tenant`, plus app-defined custom scopes |
| Read path | One query per request, memoized on `Avo::Current` |

---

## ⚠ The structural consequence of "entirely in core"

Avo core currently has **no `ActiveRecord` model of its own and no shipped
migration**. `db/` holds one dev-app migration; `Avo::Engine` never declares
`paths["db/migrate"]`. Core reads the host app's models and owns no schema.

This plan ends that. It is the right call for reach — a framework only core can
provide, that every gem declares against — but it carries three obligations that
are **not optional**:

1. **Absent table must not raise.** An app that runs `bundle update avo` before
   `rails avo:install:migrations db:migrate` must keep working, with every
   setting falling back to its code default. The store detects a missing table
   once per boot, memoizes that, and stops trying.
2. **Absent database must not raise.** Asset precompile, `rails routes`, and
   CI steps that boot the app without a database connection must not touch the
   store. Same guard covers both.
3. **The migration is generated, not auto-run.** Standard Rails engine
   pattern: `db/migrate/` in the gem, installed with
   `rails avo:install:migrations`, wired into the existing `avo:install`
   generator so new apps get it without thinking about it.

Anything that reads a setting therefore goes through one resolver with one
fallback path, and no read site ever queries directly.

---

## The declaration DSL

### Primitive

Everything reduces to one registry call:

```ruby
Avo::Settings.register(
  "avo.resources.user.default_view_type",
  as: :select,
  options: %i[table grid map],
  scopes: [:app, :user],
  default: -> { :table },
  name: "Default view type",
  help: "Which layout this resource opens in.",
  group: "Resources"
)
```

Nobody writes that by hand. Three sugars sit on top, one per place an option
gets defined.

### 1. In a resource — the common case

```ruby
class Avo::Resources::User < Avo::BaseResource
  self.default_view_type = :grid
  self.per_page = 24

  configurable :default_view_type,
    as: :select,
    options: -> { resource.available_view_types },
    scopes: [:app, :user]

  configurable :per_page, as: :number, scopes: [:app]
end
```

The key derives from the resource: `avo.resources.user.default_view_type`. The
`default:` derives from the `class_attribute` already set. `name:` derives from
the attribute, translatable via `avo.settings.*` keys. All three are
overridable.

`options:` is evaluated through `Avo::ExecutionContext` with `resource:` in
scope, so it can be dynamic — a resource with no `grid_view` never offers
`:grid` in the picker.

### 2. In the initializer — global options

```ruby
Avo.configure do |config|
  config.per_page = 24
  config.configurable :per_page, as: :number, scopes: [:app, :user]
end
```

Key: `avo.per_page`.

### 3. In a gem — via its engine handler

Gems already call `Avo.plugin_manager.register_view_type` from their engine
handler. Settings register the same way, in the same place:

```ruby
# gems/avo-kanban/lib/avo/kanban/engine_handler.rb
Avo::Settings.register(
  "avo.kanban.default_swimlane",
  as: :select,
  options: -> { Avo::Kanban.swimlanes },
  scopes: [:app, :user],
  default: :status,
  group: "Kanban"
)
```

A gem may also expose its own sugar over the primitive when it owns a class body
worth declaring in — a `Avo::Kanban::Board` subclass gets `configurable` the
same way a resource does, by including the same concern.

### Declaration options

| Option | Purpose |
| --- | --- |
| `as:` | Which Avo field renders the control — `:select`, `:boolean`, `:text`, `:number`, `:radio` |
| `options:` | Choices for `:select` / `:radio`; static array or a block resolved through `ExecutionContext` |
| `scopes:` | Which layers are **editable**. Omit a layer and it cannot be set there. Omit the declaration entirely and the option stays code-only |
| `default:` | Code-level fallback. Derived from the `class_attribute` when declared on a resource |
| `cast:` | How a stored JSON value becomes a Ruby value. Derived from `as:` — override for anything unusual |
| `authorize:` | Per-key override of who may edit the app/tenant scopes |
| `name:` / `help:` | Labels, translatable |
| `group:` | Which section of the settings screen it appears under |
| `key:` | Explicit key, when the derived one is wrong |

---

## The read seam — why this is a framework and not a feature

The whole design turns on one thing: **existing read sites do not change.**

`lib/avo/resources/base.rb:777` currently resolves the view type like this:

```ruby
def view_type
  @view_type ||= if @params[:view_type].present?
    Avo::ViewInquirer.new(@params[:view_type])
  elsif available_view_types.size == 1
    Avo::ViewInquirer.new(available_view_types.first)
  else
    Avo::ViewInquirer.new(Avo::ExecutionContext.new(
      target: default_view_type || Avo.configuration.default_view_type,
      resource: self,
      view: @view
    ).handle)
  end
end
```

That code is not touched. `configurable :default_view_type` **prepends a module
that overrides the instance reader**:

```ruby
def default_view_type
  Avo::Settings.resolve("avo.resources.user.default_view_type") { super }
end
```

`Avo::Settings.resolve` returns the highest-precedence stored value for the
current request, or yields to `super` — the `class_attribute` — when nothing is
stored, when the key is unregistered, or when the store is unavailable.

Two properties fall out of this that matter:

- **Class-level reads stay code-level.** `Avo::Resources::User.default_view_type`
  still returns `:grid`. Only the instance — which exists inside a request, where
  `Avo::Current` is populated — sees the stored value. This is what keeps the
  override out of boot-time and out of background jobs.
- **A gem opting an option in costs one line.** No read site to find, no call
  site to rewrite, no risk of missing one.

`Avo::ExecutionContext` already handles the returned value downstream, so a
stored `"grid"` string flows through the existing path unchanged.

---

## Storage

### Schema

```ruby
create_table :avo_settings do |t|
  t.string :key,        null: false, limit: 191
  t.string :scope,      null: false, limit: 40,  default: "app"
  t.string :owner_type, null: false, limit: 100, default: ""
  t.string :owner_id,   null: false, limit: 64,  default: ""
  t.text   :value
  t.timestamps
end

add_index :avo_settings, %i[key scope owner_type owner_id],
  unique: true, name: "index_avo_settings_on_key_and_owner"
```

Four choices in there are deliberate:

**`owner_type`/`owner_id` default to `""`, not `NULL`.** An app-scoped row has
no owner, and on PostgreSQL a unique index does not deduplicate `NULL`s — two
app-scoped rows for the same key would both insert. Empty strings make the
uniqueness constraint actually hold. (`NULLS NOT DISTINCT` would be cleaner and
is PG15+, which we cannot require.)

**`scope` is stored alongside the owner, not derived from it.** Two scopes can
resolve to the same record — a custom `:team_lead` scope and `:user` both point
at a `User` — and without the scope name they collide.

**`value` is `text`, not `jsonb`.** The migration ships to PostgreSQL, MySQL and
SQLite. `text` + a JSON coder is the only shape that is identical on all three.
The cost is no querying by value, which nothing needs.

**Column limits are explicit.** The composite index is 395 characters wide; on
MySQL's `utf8mb4` that is 1580 bytes, inside InnoDB's 3072-byte limit. Leaving
`limit` unset would produce a 255-char default on every column and blow past it.

### The store is one class

`Avo::Settings::Store` owns every query. Three methods: `load_for_request`,
`write`, `reset`. Nothing else in the codebase touches `avo_settings`. When
the table is missing or no connection exists, `load_for_request` returns an
empty resolved set and sets a memoized `unavailable` flag; `write` and `reset`
raise a clear `Avo::Settings::StoreUnavailable` that the controller renders as
"run the migration to enable settings".

---

## The scope chain

Scopes are ordered from least to most specific. The last one that has a value
wins.

```ruby
Avo.configure do |config|
  config.settings.scopes = [:app, :tenant, :user]
end
```

| Scope | Owner resolves from | Notes |
| --- | --- | --- |
| `app` | nothing | One row per key. Editable by admins |
| `tenant` | `Avo::Current.tenant` / `tenant_id` | Already exists on `Avo::Current`; skipped when nil |
| `user` | `Avo::Current.user` | Always editable by the user for their own value |

Custom scopes register themselves and slot into the chain by position:

```ruby
config.settings.register_scope :team,
  owner: -> { Avo::Current.user&.team },
  label: "Team",
  authorize: -> { Avo::Current.user.team_admin? }

config.settings.scopes = [:app, :tenant, :team, :user]
```

A scope whose `owner` resolves to `nil` for the current request is simply absent
from that request's chain — no row, no lookup, no error.

`scopes:` on a declaration names the layers that are **editable** for that key,
and is intersected with the configured chain. `scopes: [:app, :user]` on a key
in an app that has not enabled `:tenant` is just `[:app, :user]`; the same
declaration in a multi-tenant app still only offers app and user, because the
key's author decided a tenant-level default made no sense for it.

---

## Read path

`Avo::InitializesAvo#init_app` already sets `Avo::Current.user` and then calls
`load_appearance_settings`. The settings load goes in the same place, right
after:

```ruby
def init_app
  Avo::Current.context = context
  Avo::Current.user = _current_user
  Avo::Current.view_context = view_context
  safe_call(:before_init_app)
  Avo.init
  Avo::Current.locale = locale
  load_appearance_settings
  load_settings          # <- new
  # ...
end
```

`load_settings` issues **one query** covering every registered key across every
scope in the current request's chain, collapses the rows by precedence in Ruby,
and stores the flat result on `Avo::Current.settings`. Every subsequent
`Avo::Settings.resolve` is a hash lookup.

The query is bounded by the registry — settings for keys no longer registered
are never loaded, and never resolve, so a removed option's orphan rows are inert
rather than a problem.

This is the same pattern `Avo::Current.appearance_settings` already uses, which
is the point: nothing new to reason about, and no cache invalidation to get
wrong. If query cost ever shows up under load, the resolver is a seam a cache
drops into without touching a single read site.

---

## Write path and authorization

```ruby
Avo.configure do |config|
  config.settings.authorize_app_scope = -> { current_user.owner? }
end
```

Defaults to `Avo::Current.user_is_admin?`, which already exists and already
reads `Avo.configuration.is_admin_method`. Per-scope `authorize:` overrides it
for one layer; per-key `authorize:` overrides it for one key. The `:user` scope
needs no authorization — a user editing their own preference is always allowed,
and a user can only ever address their own row because the owner comes from
`Avo::Current.user`, never from params.

Two things the write path must get right:

**Reset deletes the row, it does not write the default.** If an admin sets the
app default to `:grid` and a user "resets" by having `:table` written to their
row, that user stops tracking the app default forever. Every control gets an
explicit reset that deletes, so the next layer down shows through again.

**The inherited value is visible.** Each control shows what it would fall back
to and where that comes from — `Inherited from App: Grid` — so the difference
between "set to table" and "not set, and app says table" is legible. Without it
nobody can tell what reset will do.

---

## UI: four surfaces, one renderer

All four surfaces render the same component. They differ only in how they filter
the registry.

| Surface | Path | Registry filter |
| --- | --- | --- |
| Global settings | `/avo/settings` | Everything, grouped by `group:`, one tab per scope the user may edit |
| Per-user preferences | `/avo/settings/profile` | Keys whose `scopes:` include `:user`, user scope only |
| Per-resource tab | `/avo/resources/users/settings` | Keys prefixed `avo.resources.user.` |
| In-context | Gear in the index toolbar | Same filter as the resource tab, rendered in a turbo-frame next to the view-type switcher |

The renderer reuses the field DSL exactly as `avo-forms` does: a plain
`Avo::Settings::Form` object exposes the registered keys as attributes,
`Avo::Concerns::HasItems` turns declarations into fields, and each declaration's
`as:` picks the input. This is the reuse the framework is for — `as: :boolean`
renders the same toggle that renders on every edit screen, and a gem adding a
setting gets that for free.

The in-context surface is the one that makes the feature discoverable. Changing
the default view is most obviously wanted while looking at the view switcher,
not three screens away in a settings panel.

---

## What ships configurable on day one

Core marks its own options, which doubles as the framework's proof:

| Key | Scopes | Field |
| --- | --- | --- |
| `avo.resources.<slug>.default_view_type` | `app`, `user` | select |
| `avo.resources.<slug>.per_page` | `app`, `user` | number |
| `avo.per_page` | `app`, `user` | number |
| `avo.resources.<slug>.default_sort_direction` | `app`, `user` | select |

Gems follow in their own releases — kanban's default swimlane, dashboards'
default period, calendar's default period and time format — each one line in the
gem, no core change.

---

## Rollout

| Phase | Contents |
| --- | --- |
| 1 | Registry, `configurable` DSL, resolver, store, migration, `Avo::Current` load, `app` + `user` scopes, global `/avo/settings` screen. Core's `default_view_type` and `per_page` configurable |
| 2 | Per-user profile page, per-resource settings tab, in-context gear |
| 3 | `tenant` scope, custom scope registration |
| 4 | Gems declare their own options |
| 5 | *(optional)* Migrate `Avo.configuration.appearance` onto the framework |

Phase 5 is deliberately last and deliberately optional. Appearance works today,
has cookie persistence and a no-database mode this framework does not, and its
`lock:` semantics predate the `scopes:` model. It becomes a consumer only if
that migration is clean — one hand-rolled implementation that works beats a
forced unification that regresses it.

---

## Open questions

**Does a URL view-type override save?** `params[:view_type]` already wins over
everything. Should clicking "grid" in the switcher be a transient override for
this request, or should it persist as the user's preference for that resource?
Transient with an explicit "make this my default" is the safer default —
persisting silently means one exploratory click permanently changes what a user
sees — but it is worth deciding before the in-context surface is built, because
it decides what that gear does.

**Key stability across renames.** Keys derive from the resource name, so
renaming `Avo::Resources::User` orphans every stored value under
`avo.resources.user.*`. Explicit `key:` is the escape hatch; whether renames
warrant a migration path or just a documented caveat is open.

**Registry timing under reload.** `Avo.boot` already rebuilds the plugin manager
under a mutex with an atomic publish. The settings registry must follow the same
begin/commit pattern or a `configurable` declaration will vanish mid-request in
development.

---

## Docs and skills impact

- `docs/4.0/` needs a new page for the framework — declaration DSL, scopes,
  authorization, the four surfaces — plus updates to every page documenting an
  option that becomes configurable.
- `avo.tt` initializer template gains the `config.settings.*` block, per the
  workspace's configuration rule.
- Core's shipped skills need a settings skill, and any skill teaching an option
  that becomes configurable needs updating — a skill that says "this can only be
  set in code" is exactly the silent-wrongness the gem-shipped-skills rule warns
  about.
