---
name: avo-filters
description: Route a filtering request to the right Avo system, then implement basic filters (developer-written Ruby filter classes) on a resource's Index view. Use when the user wants to filter, segment, or set a default view for the records on a resource index — e.g. "filter projects by status", "filter users by role", "filter by a date range", "let users build their own ad-hoc filters", "filter by an association", "only show active records by default", "add a tab for admin/active users", "segment orders into paid/unpaid tabs", or "show a count next to each tab". Covers the avo:filter generator, def filters, and the routing table that decides between basic filters, dynamic filters, and scopes. Dynamic filters and scopes are implemented by their own gems and ship their own skills — this skill points at them.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  avo-version: "4.0.24"
  requires-gem: none — basic filters are Community; this skill routes to avo-dynamic_filters and avo-scopes, which ship their own skills
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Filter and segment an Avo resource index

Avo has three separate systems for narrowing down the records on a resource's `Index` view. This skill's leading job is **routing** to the right one, then implementing it with the correct generator and DSL. Getting the routing wrong means writing the wrong kind of code, so start with the routing table below every time.

**Docs** (fetch on demand with WebFetch — the `.md` variants are agent-friendly):

- Overview / decision: https://docs.avohq.io/4.0/filters.md
- Basic filters: https://docs.avohq.io/4.0/basic-filters.md · API: https://docs.avohq.io/4.0/basic-filters-api.md
- Dynamic filters: https://docs.avohq.io/4.0/dynamic-filters.md · API: https://docs.avohq.io/4.0/dynamic-filters-api.md
- Scopes: https://docs.avohq.io/4.0/scopes.md · API: https://docs.avohq.io/4.0/scopes-api.md
- Full docs map: https://docs.avohq.io/4.0/docs-map.md

Fetch the relevant page when you need an option you don't see here (custom conditions, `fetch_values_from`, `picker_options`, per-scope `fields`, humanized pills, …). This file covers the common cases end to end.

## When this applies

The user wants to change **which records appear** on a resource's index (or an association's `has_many` listing) — filter them, let end users filter them, segment them into tabs, or pick a default view. All three systems apply to the `Index` view only and encode their state in the URL, so a filtered/segmented view can be bookmarked and shared.

Avo files live under `app/avo/`. Before editing, locate the resource (`app/avo/resources/<name>.rb`) and its model (`app/models/<name>.rb`). Use Glob (`app/avo/resources/**/*.rb`) if you're unsure of the exact path.

## Choose the right tool

Read the request against this table **first**. The three systems are independent — a resource can use any combination — but each request usually maps to exactly one.

| What the user is asking for | Use | License |
| --- | --- | --- |
| A specific, developer-defined filter with exact query logic the developer controls — "filter by status", "published/unpublished", "featured only", "by author", "by a date range". One filter = one value or checkbox set. | **Basic filter** | Community |
| End users composing their **own** filters across many attributes — pick an attribute, a condition (`Contains`, `Is`, `>=`, `Is null`), and a value, stacking several at once. "let users filter however they want", "ad-hoc filtering", "filter by an association". | **Dynamic filters** | Paid add-on |
| One-click **segment tabs** above the table — "add a tab for admins", "segment orders into paid/unpaid tabs", "Active / Archived tabs", "show a count next to each tab". | **Scopes** | Paid add-on |
| A **default view** — "only show active records by default", "hide soft-deleted by default", "default to my team's records". | **Scope** marked `default: true` (optionally with `remove_scope_all`) | Paid add-on |

Quick disambiguation:

- **"Filter" is ambiguous.** If the developer decides the exact query and offers a fixed set of choices → basic filter. If the *end user* builds the query from a palette of attributes/conditions → dynamic filters.
- **Tabs vs. filters.** A tab bar the user clicks between (mutually-exclusive segments, one active at a time) → scopes. A panel where the user sets values and applies → basic or dynamic filters.
- **"By default" / "only show X" is almost always a default scope**, not a filter — filters start empty; scopes can be pre-applied.

If the user's own words don't settle it, ask one clarifying question rather than guessing (e.g. "Do you want a fixed 'Status' filter you control, or should users build their own filters?").

**License gate:** basic filters ship in Avo's **Community** edition. **Dynamic filters and scopes are paid add-ons** (`avo-dynamic_filters` and `avo-scopes` gems). If the routing lands on dynamic filters or scopes, mention the add-on requirement in your report so the user isn't surprised when the DSL is present but nothing renders on an unlicensed install.

---

## Basic filters

One Ruby class per filter under `app/avo/filters/`. You choose the input type, define its `options`, and write the exact Active Record query in `apply`. Then register it on each resource that should show it.

### Generate

```bash
bin/rails generate avo:filter published --type select
```

`--type` accepts `boolean` (default), `select`, `multiple_select`, `text`, and `date_time`. Each maps to a base class and a value shape in `apply`:

| Type | Base class | `apply` receives |
| --- | --- | --- |
| `boolean` | `Avo::Filters::BooleanFilter` | `Hash` of `"option_id" => true/false` |
| `select` | `Avo::Filters::SelectFilter` | `String` (selected option id) |
| `multiple_select` | `Avo::Filters::MultipleSelectFilter` | `Array` of `String`s |
| `text` | `Avo::Filters::TextFilter` | `String` |
| `date_time` | `Avo::Filters::DateTimeFilter` | `String` (or `"<start> to <end>"` in range mode) |

### Write the filter

A select filter — the everyday "filter by status" case:

```ruby
# app/avo/filters/published.rb
class Avo::Filters::Published < Avo::Filters::SelectFilter
  self.name = "Published status"

  # value is a String, e.g. "published"
  def apply(request, query, value)
    case value
    when "published" then query.where.not(published_at: nil)
    when "unpublished" then query.where(published_at: nil)
    else query
    end
  end

  def options
    {published: "Published", unpublished: "Unpublished"}
  end
end
```

A boolean filter receives a hash keyed by option id — **read the keys as strings** (see Gotchas):

```ruby
# app/avo/filters/featured.rb
class Avo::Filters::Featured < Avo::Filters::BooleanFilter
  self.name = "Featured"

  # values = { "is_featured" => true, "is_unfeatured" => false }
  def apply(request, query, values)
    return query if values["is_featured"] && values["is_unfeatured"]

    if values["is_featured"]
      query.where(featured: true)
    elsif values["is_unfeatured"]
      query.where(featured: false)
    else
      query
    end
  end

  def options
    {is_featured: "Featured", is_unfeatured: "Unfeatured"}
  end
end
```

A date-time filter — for "filter by a date range". Default `self.mode` is `:range`:

```ruby
# app/avo/filters/created_at.rb
class Avo::Filters::CreatedAt < Avo::Filters::DateTimeFilter
  self.name = "Created at"
  self.type = :date    # :date_time (default), :date, or :time
  self.mode = :range   # :range (default) or :single

  def apply(request, query, value)
    from, to = value.split(" to ")           # range arrives as "2024-08-13 to 2024-08-16"
    query.where(created_at: Date.parse(from)..Date.parse(to))
  end
end
```

Text filters need no `options` (`value` is the raw string). Multiple-select filters get an `Array` of strings and `options` like select.

### Register on the resource

Filters only render once registered inside the resource's `filters` method:

```ruby
# app/avo/resources/post.rb
class Avo::Resources::Post < Avo::BaseResource
  def filters
    filter Avo::Filters::Published
    filter Avo::Filters::Featured
  end
end
```

The same filter class can be registered on many resources. To vary behavior per resource, pass `arguments: {...}` — available in `apply`, `options`, and the `self.name`/`self.visible` blocks.

### Common extras (in the guide)

- **Default state:** define `default` returning the same shape `apply` expects (`:published`, `{is_featured: true}`, `["a", "b"]`).
- **Dynamic options:** `options` is plain Ruby — query the DB or an API.
- **Conditional visibility:** `self.visible = -> { current_user.admin? }`.
- **Filters that depend on each other:** read `applied_filters` in `options`, or override `react` to change a filter's own value when another changes.
- **Link to a pre-filtered view:** `Avo::Filters::BaseFilter.encode_filters({"Avo::Filters::Name" => "Apple"})` → pass as `encoded_filters:`.

---
## Dynamic filters and scopes ship in their own gems

Both are paid add-ons, and their instructions ship inside the gem that implements them — so they describe the version this app has locked, not a guess.

| Subject | Gem | Skill to read |
| --- | --- | --- |
| End users composing ad-hoc filters — `filterable` fields, `dynamic_filter`, Ransack, the filters bar | `avo-dynamic_filters` | `avo-dynamic-filters` |
| Segment tabs, default views, per-tab counts and columns | `avo-scopes` | `avo-scopes` |

Re-run the Avo skills loader and read the skill from the path it prints for that gem. If the loader says the gem is not in `Gemfile.lock`, the app does not have it — tell the user which add-on provides the feature instead of writing DSL that will not render.

Route to them from the table above; do not reimplement their DSL from memory here.

---

## Gotchas

- **Basic filter values are always strings.** State is serialized through the URL, so `apply` receives strings and hashes with **stringified keys**. Read `values["is_featured"]`, never `values[:is_featured]`, even if you declared `options` with symbols.
- **Date-time basic filter range format.** In the default `:range` mode the value arrives as the single string `"2024-08-13 to 2024-08-16"` — split it with `value.split(" to ")`. Set `self.mode = :single` for one value.
- **Two "Filters" buttons.** If a resource has *both* basic and dynamic filters and dynamic filters' `always_expanded` is `false`, two `Filters` buttons appear on the index. The default (`always_expanded = true`) renders the dynamic bar inline and avoids the duplicate.
- **License.** Basic filters are Community. Dynamic filters and scopes are paid add-ons — their DSL is accepted but nothing renders on an install without the gem, so surface that in your report.

## Report

When done, tell the user:

- **Which system** you used and **why** it fit the request (one line of routing rationale).
- **Files created/edited** with absolute paths — the filter class(es), the resource (`def filters`), and the model.
- **License note** if the request routed to dynamic filters or scopes, along with which gem provides it.
- **Follow-ups the user must do themselves:** run the generator if you only wrote the class, or restart the server to pick up new files.
