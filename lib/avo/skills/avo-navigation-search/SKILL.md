---
name: avo-navigation-search
description: >-
  Navigate and search an Avo admin — per-resource search (`self.search`), searching across fields
  and through associations, search authorization and result limits, breadcrumbs, keyboard
  shortcuts, and the auto-generated sidebar. Use when the user wants to make a resource
  searchable, search by email or across several columns, search through an association, authorize
  or limit search results, change breadcrumbs, add a hotkey, or hide something from the sidebar.
  The menu editor DSL and the Cmd+K global palette are add-ons and ship their own skills.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — per-resource search, breadcrumbs, hotkeys and the auto sidebar are Community; the menu editor (avo-menu) and global search (avo-advanced_search) ship their own skills
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Navigation & Search

> **Two neighbouring subjects live in their own gems.** The sidebar menu **editor** DSL is `avo-menu`, and the Cmd+K **global** search palette is `avo-advanced_search` — each ships its own skill inside its own gem, pinned to that gem's version. Everything on this page is Community: per-resource search, breadcrumbs, keyboard shortcuts, and the auto-generated sidebar.
>
> Re-run the Avo skills loader to see which of those gems this app has. If it reports one missing from `Gemfile.lock`, name the add-on rather than describing a feature the app cannot use.

This skill owns everything about **getting around** an Avo admin and **finding records** in it: the three configurable menus, per-resource search, the global Cmd+K palette, breadcrumbs, and keyboard shortcuts.

Two files do almost all the work:

- **`config/initializers/avo.rb`** — the menus (`config.main_menu`, `config.profile_menu`, `config.header_menu`), the global search hash (`config.global_search`), keyboard-shortcut master switches (`config.hotkeys`), and the starting breadcrumb (`config.set_initial_breadcrumbs`).
- **`app/avo/resources/<name>.rb`** — per-resource `self.search = { query: … }` (what makes a resource searchable at all), plus `self.hotkey` and `self.visible_on_sidebar` on the resource class.

**Licensing — state this up front, it changes what you can offer:**

- The **menu editor** (`main_menu` / `profile_menu` / `header_menu` DSL) is a **paid add-on** (`avo-menu`). Without it, Avo auto-generates the sidebar from registered resources and you tune the menu only through `self.visible_on_sidebar` / `self.icon` / `self.hotkey` on each resource.
- **Global search** (the Cmd+K palette) is a **paid add-on** (`avo-advanced_search`). Without it, per-resource `self.search` still gives each resource its own Index search bar.
- **Per-resource `self.search`, breadcrumbs, and keyboard shortcuts are Community** — always available.

If the user's install lacks the add-on, say so and fall back to the Community path rather than writing DSL that won't load.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Menu editor guide: https://docs.avohq.io/4.0/menu-editor.md — API reference: https://docs.avohq.io/4.0/menu-editor-api.md
- Search guide: https://docs.avohq.io/4.0/search.md — API reference: https://docs.avohq.io/4.0/search-api.md
- Breadcrumbs: https://docs.avohq.io/4.0/breadcrumbs.md
- Keyboard shortcuts: https://docs.avohq.io/4.0/keyboard-shortcuts.md
- Authorization (the `search?` policy method): https://docs.avohq.io/4.0/authorization.md

## When this applies

**Explicit (Avo named):** "reorder the Avo sidebar", "add a `main_menu` section", "group resources in the Avo menu", "add a `link_to` to our docs in the sidebar", "hide `TeamMembership` from the Avo menu", "add `self.search` to the `User` resource", "set up the Avo global search / Cmd+K", "add a `hotkey` to a menu item", "add breadcrumbs to a custom Avo page", "add a sign-out link to the Avo profile menu".

**Implicit (product-shaped, no mention of Avo):** "organize the admin sidebar into sections", "group my models under headings", "put a billing link in the admin nav", "let non-admins not see the audit-log resource in the menu", "add a command palette / Cmd+K to the admin", "make users searchable in the admin", "let support staff look up a customer by email", "search across all records at once", "jump to Orders with a keyboard shortcut", "collapse the sidebar groups by default", "add a way to sign out from the profile dropdown".

**Boundary:** `self.search` lives on the resource file, so it overlaps the resources vertical — **this skill owns search.** For the resource file's *other* attributes (title, icon, includes, `visible_on_sidebar` semantics) cross-link **avo-resources**. For the `search?` / `index?` policy methods cross-link **avo-authorization**. For picking menu-item icon names cross-link **avo-menu-icons**; for menu/appearance styling cross-link **avo-branding-appearance**.

## Workflow

1. **Read `config/initializers/avo.rb`.** Does it already define `config.main_menu`? If yes, the menu editor is in play (edit the DSL). If no, the sidebar is auto-generated — either propose adding `config.main_menu` (needs the `avo-menu` add-on) or tune per-resource attributes.
2. **Classify the request** as *menus* (§Menus), *search* (§Search), *breadcrumbs*, or *shortcuts*. Many requests are one of these squarely; a few ("command palette that searches everything") touch both menus and search.
3. **Confirm the license** for what you're about to write — menu DSL and global search both require paid add-ons (see above). Fall back to Community equivalents when the add-on isn't present.
4. **Fetch the matching doc page** from the Docs list before writing DSL, and verify option names against it or the installed source.
5. **Edit the right file**, preserving surrounding indentation and style. Menus and global search → the initializer; `self.search` / `self.hotkey` → the resource file; breadcrumbs on a custom page → that page's controller action.
6. **Report** what you changed and any add-on / policy / model prerequisite still needed (see §Report).

---

## Menus

The sidebar menu **editor** — `config.main_menu`, `config.profile_menu`, sections, groups, sub-items, visibility rules — is the `avo-menu` add-on, and its instructions ship inside that gem. Re-run the Avo skills loader and read the **avo-menu** skill from the path it prints. If the loader reports the gem missing from `Gemfile.lock`, this app does not have it; say so rather than writing DSL that will not render, and use the Community path below.

### Community fallback (no `avo-menu`)

Without the menu editor the sidebar is auto-generated; control it from each resource file: `self.visible_on_sidebar = false` to hide, `self.icon` for the icon, `self.hotkey` for a jump shortcut. (These attributes belong to **avo-resources**; the sidebar effect is the navigation part.)

## Search

Search is configured **once per resource** via `self.search`, and that one `query:` proc powers every surface: the Index search bar, the global Cmd+K palette, searchable association pickers, and kanban card pickers. **Without `self.search`, a resource has no Index search bar and is skipped by global search.**

```ruby
# app/avo/resources/user.rb
class Avo::Resources::User < Avo::BaseResource
  self.search = {
    query: -> { query.ransack(first_name_cont: q, last_name_cont: q, m: "or").result(distinct: false) }
  }
end
```

- `q` — the stripped search string. (`params[:q]` for the raw value.)
- `query` — the base scope **with authorization scopes already applied**; always search off it.
- Avo recommends [ransack](https://github.com/activerecord-hackery/ransack) but it isn't mandatory — the proc can run any query. If using ransack, add `gem "ransack"`.

### Search by email / across fields, and through associations

```ruby
# Widen the fields searched:
query.ransack(first_name_cont: q, last_name_cont: q, email_cont: q, m: "or").result(distinct: false)
```

To match on an associated model's columns, join it and prefix the ransack keys with the association name (assuming `Application belongs_to :client`):

```ruby
class Avo::Resources::Application < Avo::BaseResource
  self.search = {
    query: -> {
      query.joins(:client).ransack(
        id_eq: q,
        name_cont: q,
        client_email_cont: q,
        client_phone_number_cont: q,
        m: "or"
      ).result(distinct: false)
    }
  }
end
```

### Different query per surface (`search_type`)

One proc can branch on `search_type` to run a wider search in the global palette than in an association picker:

```ruby
self.search = {
  query: -> {
    case search_type
    when :global       # navbar Cmd+K — widest, includes email
      query.ransack(first_name_cont: q, last_name_cont: q, email_cont: q, m: "or").result(distinct: false)
    when :association  # picker — tightest
      query.ransack(first_name_cont: q).result(distinct: false)
    else               # :resource — the Index search bar
      query.ransack(first_name_cont: q, last_name_cont: q, m: "or").result(distinct: false)
    end
  }
}
```

`search_type` is `:resource`, `:global`, or `:association`. It is **injected only by the paid search layer** (`avo-advanced_search`) — on a Community-only install the local is undefined and referencing it raises. The kanban card picker doesn't inject it (or a `q` local) either. Guard with `defined?(search_type)` when a Community install or the kanban picker might hit the proc; the kanban picker reads the term from `params[:q]`.

### Authorize search

Search obeys the `search?` policy method — if it returns false the resource is dropped from global search and its Index search bar is hidden.

```ruby
class UserPolicy < ApplicationPolicy
  def search?
    true
  end
end
```

(If `search?` is already used for something else, alias it via `config.authorization_methods = { search: "avo_search?" }`.) See **avo-authorization**.

### Limit results

Avo caps each resource's results at `config.search_results_count` (default `8`) — **unless your proc already calls `.limit()`, in which case your limit wins**. The dedicated global results page ignores the cap.

```ruby
config.search_results_count = 16   # global, in the initializer
# or per resource: query.ransack(name_cont: q).result(distinct: false).limit(current_user.admin? ? 30 : 10)
```

### Global search (Cmd+K palette)

One palette spanning every resource is the `avo-advanced_search` add-on, and its instructions ship inside that gem — read the **avo-advanced-search** skill from the path the loader prints. Everything above on this page is Community and works without it.

### Custom (non-ActiveRecord) providers

Back search with Elasticsearch etc. by returning an **array of hashes** from `query:` instead of a relation:

```ruby
query: -> {
  [
    { _id: 1, _label: "Record One", _url: "https://example.com/1", _description: "…", _avatar: "https://…", _avatar_type: :rounded }
  ].first(config_or_number)   # array results are NOT auto-capped — cap yourself
}
```

---

## Breadcrumbs (Community)

Avo builds a breadcrumb trail automatically for resource views. Two things you'd configure:

**Change where every trail starts** — `config.set_initial_breadcrumbs` in the initializer (runs in controller context; use the `avo` proxy for engine paths):

```ruby
# config/initializers/avo.rb
config.set_initial_breadcrumbs do
  add_breadcrumb title: "Home", path: avo.root_path, icon: "tabler/outline/home"
  add_breadcrumb title: "Team", path: avo.resources_teams_path
end
# Leave the block empty to start trails with no initial crumbs.
```

**Add crumbs on a custom page** — call `add_breadcrumb` in the page's controller action:

```ruby
class Avo::ToolsController < Avo::ApplicationController
  def custom_tool
    add_breadcrumb title: "Custom tool", path: avo.custom_tool_path   # omit path: for the current (unlinked) crumb
  end
end
```

`add_breadcrumb` options: `title:` (required), `path:` (omit → plain text), `icon:`, `initials:`, `avatar:`. Internal Avo links need the `avo.` prefix (Rails engine path rules).

## Keyboard shortcuts (Community)

All shortcuts are on by default; each bound control shows a small `<kbd>` badge, and `?` opens the reference modal for the current page. Shortcuts never fire while typing in an input/textarea/select/contenteditable.

```ruby
# config/initializers/avo.rb
config.hotkeys = {
  enabled: true,          # master switch
  show_key_badges: true   # inline <kbd> badges next to buttons/links
}
```

Built-in highlights: `Cmd/Ctrl+K` global search · `Shift+\` toggle sidebar · `B` go back · `/` focus Index search · `C` new record · `A` actions menu · `V T` / `V G` / `V M` switch table/grid/map view. (Full table on the keyboard-shortcuts doc page.)

Add your own on any control with a `data-hotkey` attribute (re-bound on every Turbo navigation):

```html
<a href="/avo/posts/new" data-hotkey="c">New post</a>
<button data-hotkey="Meta+Enter Control+Enter">Save</button>  <!-- space = platform alternatives -->
```

Jump-to-menu-item shortcuts go through the menu `hotkey:` option, or `self.hotkey` on the resource class (see §Menus).

---

## Gotchas

- **Menu editor and global search are paid add-ons.** Writing `config.main_menu` or relying on the Cmd+K palette on an install without `avo-menu` / the global-search add-on won't work — check first, and fall back to per-resource `self.visible_on_sidebar` / `self.search` (both Community).
- **`all_resources` respects `index?` authorization.** A resource missing from the menu is usually a policy returning false, not a bug.
- **Menu `action` items must be standalone.** `self.standalone = true` is required (the menu has no selected record); others are skipped with a log warning. Top-level `action` also needs `resource:`; nested it's inherited.
- **`profile_menu` and `header_menu` render only `link_to`.** `resource`, `dashboard`, `action`, etc. are silently ignored there. The profile menu adds sign-out for you.
- **`icon:` isn't universal.** It works on `section` and individual items, **not** on `group` or on sub-items nested inside a `resource` block.
- **Ransack v4+ needs an allowlist.** Add `ransackable_attributes` (and often `ransackable_associations`) to any model you search, or the query raises.
- **`search_type` is undefined on Community-only installs and in the kanban picker.** It's injected by the paid search layer for the index/global/association surfaces only. Guard with `defined?(search_type)`; the kanban picker reads `params[:q]` and detects the board via `params[:for_kanban_board]`.
- **Custom array-result providers aren't auto-capped.** `config.search_results_count` only applies to relations without their own `.limit()` — cap arrays yourself with `.first(N)`.
- **`.limit()` in your `query:` proc always wins** over `config.search_results_count`.
- **`search_on_type` can't be a lambda.** Any Proc is truthy, so it behaves as `true`; use a plain boolean. (`enabled` and `navigation_section` do accept lambdas.)
- **`self.description` and search `item` titles can render raw HTML** in adjacent surfaces — never interpolate user-editable content (stored-XSS). See **avo-resources**.
- **Internal breadcrumb/menu paths need the `avo.` prefix** (Rails engine path helper rules), e.g. `avo.resources_teams_path`.

## Report

When done, tell the user:

- Which file(s) you edited (full paths) — the initializer, which resource file(s), and/or which custom-page controller.
- What you changed: menu structure (sections/groups/items added, reordered, or hidden), which `self.search` procs you added and the fields/associations they cover, global-search settings, breadcrumbs, or hotkeys.
- Any **add-on** the change depends on (`avo-menu` for the menu DSL, `avo-advanced_search` for Cmd+K global search) and whether it appears to be installed.
- Any **prerequisite still needed**: a policy method (`index?` for `all_resources`, `search?` for search — see **avo-authorization**), `ransackable_attributes` on the searched model, `self.standalone = true` on a menu action, or `gem "ransack"`.
- Note when you fell back to a Community path (per-resource `visible_on_sidebar` / `self.search`) because an add-on wasn't present.
