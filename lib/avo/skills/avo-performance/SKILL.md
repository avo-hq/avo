---
name: avo-performance
description: Make the Avo admin fast and fix stale or wrong cached rows — pick and force a cache store (config.cache_store, Solid Cache), control index row caching (cache_resources_on_index_view, index_cache_context, cache_hash), and bust stale caches. Use when the user wants to speed up the admin, cache admin index rows, or fix caching side-effects — both Avo phrasings ("speed up the Avo admin", "why is the Avo index slow", "set up Solid Cache for Avo", "override cache_hash on a resource", "disable cache_resources_on_index_view") and Rails-shaped ones without Avo ("the admin is slow / the index page takes forever", "speed up the admin", "admin rows don't update after I change a related record", "stale data on the admin list", "admin links point to the old mount path after I moved it", "cache admin index rows"). For N+1 on the index — the single biggest slowness cause — see the self.includes option in avo-resources.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Performance & Caching

Avo leans on the application's cache to speed up the admin, most visibly by caching **each item on the Grid view** (table rows are rendered on every request today; caching them is a follow-up). This skill covers the two levers that decide how fast an Avo screen feels: **eliminating N+1 queries** (the biggest cause of a slow index, handled by the sibling **avo-resources** skill) and **caching index rows correctly** so they're fast *and* accurate. The flip side of caching is stale rows — a record that still shows the old value after an associated record changed, or a link that still points at the old mount path — and most requests that land here are really "the admin is slow" or "the admin shows stale data." Cache config is global, in `config/initializers/avo.rb`; the record's part of a row's cache key is a resource method (`cache_hash`) at `app/avo/resources/<name>.rb`, the viewer's part is `config.index_cache_context` (or a resource's `cache_context`).

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Performance & caching: https://docs.avohq.io/4.0/performance.md
- `cache_hash` reference: https://docs.avohq.io/4.0/resources-api.md#cache_hash
- Solid Cache: https://github.com/rails/solid_cache

## When this applies

**Explicit (Avo named):** "speed up the Avo admin", "cache the Avo index rows", "why is the Avo index slow", "set `config.cache_store` / use Solid Cache with Avo", "turn off `cache_resources_on_index_view`", "override `cache_hash` on the `User` resource", "Avo keeps showing a stale cached row".

**Implicit (Rails-shaped, no mention of Avo):** "the admin is slow", "the admin index page takes forever to load", "speed up the admin", "cache the admin index rows", "the admin list shows stale data", "admin rows don't update after I change a related record", "a comment count on the admin doesn't refresh when I add a comment", "admin links point to the old mount path after I moved the admin", "I changed where the admin is mounted and its links are broken".

If the complaint is purely load time (not staleness), **check N+1 first** — see step 1. Caching hides N+1 on warm requests but the cold request and any cache miss stay slow.

## Workflow

### 1. Rule out N+1 before touching cache config

The most common reason an Avo index is slow is N+1 queries from association or attachment fields, **not** missing cache. Caching only masks it on cache hits. Eager-load on the resource before anything else — this is the **avo-resources** skill's `self.includes` / `self.attachments`:

```ruby
# app/avo/resources/post.rb
class Avo::Resources::Post < Avo::BaseResource
  self.includes = [:user, :tags]     # associations shown on Index
  self.attachments = [:cover_photo]  # Active Storage attachments on Index
end
```

To *see* where time goes, optionally turn on ViewComponent instrumentation (step 6) — but only in development, it's a perf cost itself.

### 2. Understand which cache store Avo is using

Avo picks its store automatically:

- **Production** → `Rails.cache`, **unless** that's a `MemoryStore` or `NullStore`; then Avo falls back to `:file_store` at `tmp/cache`.
- **Every other environment** (development, test, custom) → always `:file_store` at `tmp/cache`.

So on a fresh app with the default `MemoryStore`, Avo is silently on the file store in production. That's usually the thing to fix — move to a real shared store (step 4).

Check what's live from the Rails console:

```ruby
Avo.cache_store.class   # what Avo actually uses
Rails.cache.class       # what the app is configured with
```

### 3. Force a specific cache store (optional)

Override Avo's choice with `config.cache_store`. It takes a store **object**, or a lambda when you want different stores per environment:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.cache_store = ActiveSupport::Cache.lookup_store(:solid_cache_store)

  # lambda form — evaluated per request, handy for env-specific stores:
  config.cache_store = -> { ActiveSupport::Cache.lookup_store(:solid_cache_store) }
end
```

### 4. Set up Solid Cache (recommended production store)

Avo integrates cleanly with [Solid Cache](https://github.com/rails/solid_cache) — a DB-backed store that's shared across all Puma workers and processes. Install:

```bash
bundle add solid_cache
bin/rails solid_cache:install:migrations
bin/rails db:migrate
```

Point Rails at it (Avo will then use it automatically, since it's `Rails.cache`):

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

You only need `config.cache_store` in the Avo initializer (step 3) if you want Avo on a *different* store than the rest of the app.

### 5. Control index row caching

Row caching is on by default everywhere except development. Every cached row is keyed on the record **and on the viewer** — the current user record, `I18n.locale` and `Avo::Current.tenant_id` — so a field shown or hidden per role, a computed field reading `current_user`, or a grid card lambda is cached per user and never served to another one. Cached rows expire after a day. Three knobs:

```ruby
# config/initializers/avo.rb
config.cache_resources_on_index_view = false   # disable row caching entirely
config.index_cache_context = -> { [current_user, I18n.locale, Avo::Current.tenant_id] }   # the default
```

- **`cache_resources_on_index_view`** — Boolean. Default: enabled in every environment except development. You no longer need to turn it off for role-based fields; the viewer is in the key. Turn it off only when a row reads something the key cannot carry (see the Gotchas).

- **`index_cache_context`** — lambda, resolved through `Avo::ExecutionContext` (`current_user`, `params`, `request`, `context` available) **once per request** and appended to every row's key. Default: `[current_user, I18n.locale, Avo::Current.tenant_id]`. The user *record* goes in, not its id — a role edit touches `updated_at` and busts that user's rows on the spot. Narrow it to share cached rows across users who see identical rows, **only** when nothing a row renders reads the user:

```ruby
# config/initializers/avo.rb
config.index_cache_context = -> { [current_user.role, I18n.locale] }
```

  A resource can override the resolved value with its own `cache_context` method — do that only for a per-request dimension a lambda reads that is *not* the user, e.g. a currency kept in `Avo::Current.context`:

```ruby
# app/avo/resources/order.rb
class Avo::Resources::Order < Avo::BaseResource
  def cache_context
    [*super, Avo::Current.context[:currency]]
  end
end
```

- **`cache_hash(parent_record)`** — the resource method for the *record's* part of the key. The default is `[record, file_hash]` (plus the parent record in association tables). `file_hash` is an MD5 of the **resource file and its policy file**, so editing either one auto-busts every cached row for that resource — but a change to the *data* or to an *association* does not, unless you tell it to (see *Fixing stale / incorrect cached rows* below). Override it per resource to fold more of the record's data into the key; the viewer stays in the key regardless, because the final key is `index_cache_key(parent_record)` = `[*cache_hash(parent_record), *cache_context]`:

```ruby
# app/avo/resources/user.rb
class Avo::Resources::User < Avo::BaseResource
  def fields
    # ...
  end

  def cache_hash(parent_record)
    # include record.post so the row re-renders when the post changes
    result = [record, file_hash, record.post]
    result << parent_record if parent_record.present?
    result
  end
end
```

### 6. Log ViewComponent render times (development only)

Avo's UI is ViewComponents; to profile them like partials, enable instrumentation and a log subscriber:

```ruby
# config/application.rb or config/environments/development.rb
config.view_component.instrumentation_enabled = true
```

```ruby
# config/initializers/view_component.rb
module ViewComponent
  class LogSubscriber < ActiveSupport::LogSubscriber
    define_method :'!render' do |event|
      info do
        message = +"  Rendered #{event.payload[:name]}"
        message << " (Duration: #{event.duration.round(1)}ms"
        message << " | Allocations: #{event.allocations})"
      end
    end
  end
end

ViewComponent::LogSubscriber.attach_to :view_component
```

Keep this in development only — it measurably slows down rendering, so don't leave it on in production.

## Fixing stale / incorrect cached rows

Because each Grid item is cached, a row can lag reality. The usual cases:

- **Row doesn't update when an associated record changes** (e.g. a `Post` row showing a stale comment count after a `Comment` is added). Two fixes, pick one:
  - Add `touch: true` on the child's `belongs_to`, so writing the child touches the parent and moves it out of its cache key:
    ```ruby
    class Comment < ApplicationRecord
      belongs_to :post, touch: true
    end
    ```
  - Or fold the association into the resource's `cache_hash` (step 5) so the key changes when the association changes.

- **Links point at the old mount path after you move the admin** (`root_path` change). Cached rows cache the control/`belongs_to`/`record_link` URLs too, and a `root_path` change does **not** invalidate those keys. Clear the cache once with `Rails.cache.clear`, or add `root_path` to the resource's `cache_hash`.

These are ordinary Rails caching side-effects, not Avo bugs — the same reasoning applies to fragment caching anywhere.

## Gotchas

- **N+1 first, cache second.** A slow index is almost always missing `self.includes`/`self.attachments` (the **avo-resources** skill), not missing cache. Caching only helps warm requests; the cold request stays slow. Fix the queries before tuning the store.
- **Don't use `MemoryStore` in production.** It isn't shared across Puma workers/processes, so each worker holds a different cache. Avo rejects it and silently falls back to `:file_store` at `tmp/cache` — which is why a "cached" prod app can still feel slow. Use a shared store (Solid Cache, Redis, Memcached).
- **Stale rows when associations change.** A row won't re-render on an associated change by itself → add `belongs_to …, touch: true` on the child, or add the association to the resource's `cache_hash`.
- **Moving the admin doesn't bust cached links.** Changing `root_path` leaves cached row URLs pointing at the old mount path → `Rails.cache.clear` once, or add `root_path` to `cache_hash`.
- **Editing the resource or policy file *does* bust the cache automatically** — `file_hash` (part of the default `cache_hash`) hashes both files. So config changes take effect immediately; only *data*/*association* changes need the fixes above.
- **Role-based fields are safe under caching; don't turn it off for them.** The row key is user-scoped by default (`index_cache_context` puts the current user record, locale and tenant in it), so per-role `visible:` lambdas, authorization-driven fields and grid cards are cached per user. Override `cache_context` only for a per-request dimension a lambda reads that is *not* the user. Role-based field visibility itself is the **avo-authorization** skill's territory.
- **A key can't vary by what it doesn't contain.** A `visible:` or computed field that reads `params` (a query-string flag, a filter value) is served from whichever request cached the row first, under any key. Put the value in `index_cache_context` if it is a small, bounded set; otherwise set `config.cache_resources_on_index_view = false` for that app.
- **Only the Grid view caches per row today.** Table rows render on every request, so a stale-table complaint is not a cache problem — look at N+1 (step 1) instead.
- **ViewComponent logging is a dev tool.** Instrumentation slows rendering; enable it to profile, then remove it — never leave it on in production.
- **Verify before writing.** Option names and defaults drift between versions — confirm against the docs URLs above or the app's installed Avo source (`Avo.cache_store`, `Avo.configuration.cache_resources_on_index_view`) rather than trusting memory.

## Report

When done, tell the user:

- What you diagnosed — N+1 vs. cold-cache vs. staleness — and how you confirmed it (e.g. `Avo.cache_store.class`, ViewComponent timings, missing `self.includes`).
- Which files you changed (full paths): the initializer (`config.cache_store`, `config.cache_resources_on_index_view`, `config.index_cache_context`), any resource `cache_hash` or `cache_context` override, model `touch: true`, Solid Cache install/migration.
- The cache store now in effect and why (default pick vs. forced), plus any commands run (`bundle add`, `solid_cache:install:migrations`, `db:migrate`, `Rails.cache.clear`).
- For staleness fixes: exactly what now busts the cache (touch, `cache_hash` addition, or a one-time clear) and any change still needed elsewhere (add `self.includes` in avo-resources, disable row caching for fields that read `params`, run pending migrations).
- Anything left for the user: restart/redeploy so initializer changes load, warm the cache, or verify the store is reachable in production.
