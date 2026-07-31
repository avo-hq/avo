---
name: avo-performance
description: Make the Avo admin fast and fix stale or wrong cached rows — pick and force a cache store (config.cache_store, Solid Cache), control index row caching (cache_resources_on_index_view, cache_hash), and bust stale caches. Use when the user wants to speed up the admin, cache admin index rows, or fix caching side-effects — both Avo phrasings ("speed up the Avo admin", "why is the Avo index slow", "set up Solid Cache for Avo", "override cache_hash on a resource", "disable cache_resources_on_index_view") and Rails-shaped ones without Avo ("the admin is slow / the index page takes forever", "speed up the admin", "admin rows don't update after I change a related record", "stale data on the admin list", "admin links point to the old mount path after I moved it", "cache admin index rows"). For N+1 on the index — the single biggest slowness cause — see the self.includes option in avo-resources.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  avo-version: "4.0.24"
  requires-gem: none — Community
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Avo Performance & Caching

Avo leans on the application's cache to speed up the admin, most visibly by caching **each row on the Index view** (and each item on the Grid view). This skill covers the two levers that decide how fast an Avo screen feels: **eliminating N+1 queries** (the biggest cause of a slow index, handled by the sibling **avo-resources** skill) and **caching index rows correctly** so they're fast *and* accurate. The flip side of caching is stale rows — a record that still shows the old value after an associated record changed, or a link that still points at the old mount path — and most requests that land here are really "the admin is slow" or "the admin shows stale data." Cache config is global, in `config/initializers/avo.rb`; per-row cache keys are a resource method (`cache_hash`) at `app/avo/resources/<name>.rb`.

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

Row caching is on by default everywhere except development. Two knobs:

```ruby
# config/initializers/avo.rb
config.cache_resources_on_index_view = false   # disable row caching entirely
```

- **`cache_resources_on_index_view`** — Boolean. Default: enabled in every environment except development. Turn it off when cached rows would leak the wrong content between requests — most importantly when fields are **shown/hidden per role** (see the Gotchas, and the **avo-admin-config** and **avo-authorization** skills).

- **`cache_hash(parent_record)`** — the resource method that computes each row's cache key. The default is `[record, file_hash]` (plus the parent record in association tables). `file_hash` is an MD5 of the **resource file and its policy file**, so editing either one auto-busts every cached row for that resource — but a change to the *data* or to an *association* does not, unless you tell it to (step 6 below and the next section). Override it per resource to fold more into the key:

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

Because each Index row is cached, a row can lag reality. The usual cases:

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
- **Turn off row caching when fields depend on the viewer.** If you show/hide or change fields **by role** (per-user visibility, authorization-driven fields), a row cached for one user can be served to another. Set `config.cache_resources_on_index_view = false` — the flag is listed in the **avo-admin-config** skill, and role-based field visibility is the **avo-authorization** skill's territory.
- **ViewComponent logging is a dev tool.** Instrumentation slows rendering; enable it to profile, then remove it — never leave it on in production.
- **Verify before writing.** Option names and defaults drift between versions — confirm against the docs URLs above or the app's installed Avo source (`Avo.cache_store`, `Avo.configuration.cache_resources_on_index_view`) rather than trusting memory.

## Report

When done, tell the user:

- What you diagnosed — N+1 vs. cold-cache vs. staleness — and how you confirmed it (e.g. `Avo.cache_store.class`, ViewComponent timings, missing `self.includes`).
- Which files you changed (full paths): the initializer (`config.cache_store`, `config.cache_resources_on_index_view`), any resource `cache_hash` override, model `touch: true`, Solid Cache install/migration.
- The cache store now in effect and why (default pick vs. forced), plus any commands run (`bundle add`, `solid_cache:install:migrations`, `db:migrate`, `Rails.cache.clear`).
- For staleness fixes: exactly what now busts the cache (touch, `cache_hash` addition, or a one-time clear) and any change still needed elsewhere (add `self.includes` in avo-resources, disable row caching for role-based fields, run pending migrations).
- Anything left for the user: restart/redeploy so initializer changes load, warm the cache, or verify the store is reachable in production.
