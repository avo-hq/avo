---
name: avo-multitenancy
description: Scope the Avo admin per tenant — account, team, or organization — so each customer only sees their own data. Covers route-based tenancy (mount Avo under /:tenant_id + config.default_url_options + a set_tenant before_action) and session-based tenancy with an account switcher, all built on the Avo::Current.tenant / tenant_id attributes you populate yourself. Use when the user wants to scope the admin per account/team/org, make each customer see only their own data in the admin, add tenant scoping, build a multi-tenant admin, add an account/tenant switcher, mount the admin under /:account_id, or have the admin switch data based on the current account — including Rails-shaped requests with no mention of Avo like "the admin should switch data based on the current account" or "each client should only see their own records."
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community (subdomain/multi-URL tenancy needs a special license)
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Multitenancy

Multitenancy adds a layer just below authentication: a signed-in user no longer acts as *themselves* but *on behalf of a tenant* — an `Account`, a `Team`, an `Organization`, whatever you model. The job of this skill is to answer one question on every request: **which tenant is the current user acting for?** — and to make Avo scope its data to it.

The whole thing hangs on two attributes Avo ships on `Avo::Current`: **`tenant_id`** and **`tenant`**. Both are deliberately left empty — Avo never populates them. **There is no `config.tenant` option and no dedicated setting**; you set the values yourself in a `before_action`, and your resources/queries then read `Avo::Current.tenant` to filter. Everything below is a recipe for doing that cleanly, either from the URL (route-based) or from the session (session-based).

Authentication ("who is signed in") is the layer *above* this — that's the **avo-authentication** skill, and it's a prerequisite: `Avo::Current.user` must resolve before you can look up which accounts they belong to.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Multitenancy guide: https://docs.avohq.io/4.0/multitenancy.md
- `Avo::Current` (the `tenant` / `tenant_id` attributes): https://docs.avohq.io/4.0/avo-current.md
- `config.default_url_options` reference: https://docs.avohq.io/4.0/customization-api.md
- Acts As Tenant integration (subdomain / row-level): https://docs.avohq.io/4.0/guides/acts_as_tenant_integration.md

License: **Community** (built into every Avo install). One exception: **subdomain / multi-URL tenancy** (e.g. `acct-a.example.com`, `acct-b.example.com`) is one application per URL and needs a special license — reach out to avohq.io. Path-based (`/:tenant_id`) and session-based tenancy on a single URL are Community.

## When this applies

**Explicit (Avo named):** "populate `Avo::Current.tenant` / `tenant_id`", "mount Avo under `/:tenant_id`", "set `config.default_url_options` for multitenancy", "add a `set_tenant` before_action", "scope Avo resources to the current account/team", "build an account switcher for Avo".

**Implicit (Rails-shaped, no mention of Avo):** "scope the admin per account / team / organization", "each customer should only see their own data in the admin", "make the admin multi-tenant", "add tenant scoping", "add an account / tenant switcher", "mount the admin under `/:account_id`", "the admin should switch the data based on the current account", "each client should only see their own records in the admin panel".

Pick the strategy from what the user describes:

- Tenant should live **in the URL** (`/foo/resources/...`, shareable/bookmarkable per tenant, deep links carry the tenant) → **Route-based tenancy**.
- Tenant should be **remembered per session** and toggled with a switcher, URL unchanged → **Session-based tenancy**.
- Tenant should be a **subdomain** with row-level scoping via a gem → point at **Acts As Tenant** (special license; see Docs).

## Workflow

First confirm authentication is wired (`Avo::Current.user` resolves — see **avo-authentication**), then read `config/routes.rb` and `config/initializers/avo.rb` to see what exists, and apply only what's missing. In the examples below the tenant model is `Account`; substitute the app's real tenant model (`Team`, `Organization`, …).

### Route-based tenancy

The user hits `https://example.com/foo/...` and everything scopes to the `foo` tenant. Three pieces, all required.

**1. Mount Avo under the tenant scope.** Wrap `mount_avo` in a `scope "/:tenant_id"`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope "/:tenant_id" do
    mount_avo
  end
end
```

**2. Keep the tenant in every generated URL.** Because Avo now lives under `/:tenant_id`, every path Avo generates must carry that segment or the links drop the tenant and 404. Add it to `config.default_url_options` and Avo appends `params[:tenant_id]` to every path it builds:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.default_url_options = [:tenant_id]
end
```

This is **not optional** — skip it and navigation breaks the moment you click a second link. `default_url_options` also accepts a block (returning an array) when the value must be computed, but the array form is what route-based tenancy needs.

**3. Set the tenant on each request.** Extract the id from `params[:tenant_id]` in a `prepend_before_action`, packaged as a concern and included into `Avo::ApplicationController`:

```ruby
# app/controllers/concerns/multitenancy.rb
module Multitenancy
  extend ActiveSupport::Concern

  included do
    prepend_before_action :set_tenant
  end

  def set_tenant
    Avo::Current.tenant_id = params[:tenant_id]
    Avo::Current.tenant = Account.find(params[:tenant_id])
  end
end
```

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  # configuration values (including default_url_options from step 2)
end

Rails.configuration.to_prepare do
  Avo::ApplicationController.include Multitenancy
end
```

Now visiting `https://example.com/foo` sets `Avo::Current.tenant_id` to `"foo"` and `Avo::Current.tenant` to that `Account`. Your resources read `Avo::Current.tenant` to filter records (e.g. scope `query` in the resource, or `default_scope`/`acts_as_tenant` on the model).

### Session-based tenancy

Simpler — the routing is untouched, the tenant is remembered in the session and changed with a switcher.

**1. Set the tenant from the session on each request.** Same concern-included-via-`to_prepare` shape, but read the id from `session` with a sensible fallback:

```ruby
# app/controllers/concerns/multitenancy.rb
module Multitenancy
  extend ActiveSupport::Concern

  included do
    prepend_before_action :set_tenant
  end

  def set_tenant
    Avo::Current.tenant = Account.find(session[:tenant_id] || current_user.accounts.first.id)
  end
end
```

```ruby
# config/initializers/avo.rb
Rails.configuration.to_prepare do
  Avo::ApplicationController.include Multitenancy
end
```

**2. Add an account switcher** — a route, a controller that writes the session, and a partial that renders the links:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  put "switch_account/:id", to: "avo/switch_accounts#update", as: :switch_account
end
```

```ruby
# app/controllers/avo/switch_accounts_controller.rb
class Avo::SwitchAccountsController < Avo::ApplicationController
  def update
    # set the new tenant in session
    session[:tenant_id] = params[:id]

    redirect_back fallback_location: root_path
  end
end
```

```erb
<%# app/views/avo/_session_switcher.html.erb %>
<% current_user.accounts.each do |account| %>
  <%= link_to account.name, switch_account_path(account.id), class: class_names({"underline": session[:tenant_id].to_s == account.id.to_s}), data: {turbo_method: :put} %>
<% end %>
```

The switch route is defined in the **main app's** `routes.draw` (not inside a scope), and `Avo::SwitchAccountsController` subclasses `Avo::ApplicationController` so the `set_tenant` before_action and Avo's auth still run. You then render `_session_switcher` somewhere visible in the admin (a custom sidebar / resource tool / view override) — the docs supply the partial but not the mount point, so wire it into wherever the app surfaces admin chrome.

### Subdomain / row-level (Acts As Tenant)

If the ask is subdomain-per-tenant (`sah.example.org`) or row-level DB scoping via the [`acts_as_tenant`](https://github.com/ErwinM/acts_as_tenant) gem, don't hand-roll it — follow the dedicated **Acts As Tenant integration** guide (see Docs). Note the license caveat: more than one URL per app needs a special Avo license.

## Gotchas

- **There is no config option for the tenant.** `Avo::Current.tenant` / `tenant_id` are empty attributes Avo never fills. You *must* set them yourself in a `before_action` — if you're hunting for a `config.tenant =` setting, it doesn't exist. Verified in Avo source: the two attributes carry the comment "here so the user can add them on their own will."
- **Route-based tenancy without `config.default_url_options = [:tenant_id]` silently breaks navigation.** The first page renders (its URL already has the segment), but every link Avo generates omits the tenant and 404s. This is the single most common route-based mistake. The `customization-api` example uses `[:account_id]` — match the array element to your actual scope param name.
- **Include the concern via `Rails.configuration.to_prepare`, not a bare `include` at the top of the initializer.** `Avo::ApplicationController` is reloaded in development; a one-time include is lost on the next reload and `set_tenant` stops firing. `to_prepare` re-runs on every reload so the concern survives. See **avo-engine-internals** for why `Avo::Current` and the engine's controllers behave this way.
- **`Avo::ApplicationController` does not inherit from your app's `ApplicationController`.** App helpers, concerns, and before_actions aren't available inside it. Keep `set_tenant` self-contained (use `params`, `session`, `current_user`, `Avo::Current`); to share real app logic, extend Avo's base controller the supported way — the **avo-controllers** skill.
- **Prefer `prepend_before_action`.** The tenant must be set *before* any other Avo before_action that might read `Avo::Current.tenant` (authorization scopes, resource queries), so prepend it to run first.
- **Authentication is a prerequisite.** `current_user` / `Avo::Current.user` must resolve before session-based `set_tenant` can call `current_user.accounts` — a `nil` user raises here. Wire auth first (**avo-authentication**).
- **Setting the tenant ≠ filtering the data.** These recipes only populate `Avo::Current.tenant`. You still have to *use* it — scope your resources' `query`, add a model `default_scope`, or use `acts_as_tenant` — or every tenant will keep seeing every record.
- **Handle a missing/invalid tenant.** `Account.find(params[:tenant_id])` raises `RecordNotFound` on a bad or absent segment, and you should also confirm the current user is actually a member of that tenant — otherwise the URL is an authorization hole where anyone can swap the id to view another tenant's admin.
- **Verify before writing.** Names drift between versions — confirm `default_url_options`, the `Avo::Current` attributes, and `mount_avo` against the docs URLs above or the app's installed Avo source rather than trusting memory.

## Report

When done, tell the user:

- Which files you touched (full absolute paths) — typically `config/routes.rb`, `config/initializers/avo.rb`, `app/controllers/concerns/multitenancy.rb`, and for session-based tenancy `app/controllers/avo/switch_accounts_controller.rb` + `app/views/avo/_session_switcher.html.erb`.
- Which strategy you implemented (route-based vs session-based) and how the tenant is resolved each request (`params[:tenant_id]` vs `session[:tenant_id]`), plus — for route-based — that `config.default_url_options` is set so links keep the tenant.
- That `Avo::Current.tenant` / `tenant_id` are now populated, and the explicit next step: **actually scope the data** (resource `query`, model scope, or `acts_as_tenant`) — setting the tenant alone does not filter records.
- Any gaps left for the user: where to render `_session_switcher`, the membership check guarding against tenant-id tampering, and — if they asked for subdomains — the special-license caveat and the Acts As Tenant guide.
- Handoffs: **avo-authentication** if `current_user` isn't wired yet; **avo-controllers** if `set_tenant` needs shared app logic; **avo-authorization** to enforce per-tenant record access with policies.
