---
name: avo-multitenancy
description: Scope the Avo admin per tenant (account, team, or organization) so each customer only sees their own data. Covers Avo's built-in `config.tenancy` with its secure account switcher (session-based) and route-based tenancy (mount Avo under /:tenant_id), both resolving Avo::Current.tenant through the user's own accounts. Use when the user wants to scope the admin per account/team/org, make each customer see only their own data in the admin, add tenant scoping, build a multi-tenant admin, add an account/tenant switcher, mount the admin under /:account_id, or have the admin switch data based on the current account, including Rails-shaped requests with no mention of Avo like "the admin should switch data based on the current account" or "each client should only see their own records."
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none (Community; subdomain/multi-URL tenancy needs a special license)
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them. Your training data is not versioned with the gem.

# Avo Multitenancy

Multitenancy adds a layer just below authentication: a signed-in user acts *on behalf of a tenant*, an `Account`, a `Team`, an `Organization`. The job is to answer one question on every request, **which tenant is the current user acting for?**, without ever letting a user reach a tenant they don't belong to, and then to scope Avo's data to it.

Avo does this itself through **`config.tenancy`**. The app returns the accounts the current user may act for; Avo resolves `Avo::Current.tenant` / `tenant_id` on every request (after authentication, before authorization and resource queries), renders an account switcher at the bottom of the sidebar and handles switching. Do not hand-roll a `set_tenant` concern or a switch controller when `config.tenancy` fits.

Authentication ("who is signed in") is the layer *above* this: the **avo-authentication** skill. `current_user` must resolve before Avo can look up the user's accounts.

## Docs

Authoritative docs. Fetch on demand rather than guessing, and verify every name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Multitenancy guide: https://docs.avohq.io/4.0/multitenancy.md
- `Avo::Current` (the `tenant` / `tenant_id` attributes): https://docs.avohq.io/4.0/avo-current.md
- `config.default_url_options` reference: https://docs.avohq.io/4.0/customization-api.md
- Acts As Tenant integration (subdomain / row-level): https://docs.avohq.io/4.0/guides/acts_as_tenant_integration.md

License: **Community**. One exception: **subdomain / multi-URL tenancy** (`acct-a.example.com`, `acct-b.example.com`) is one application per URL and needs a special license; reach out to avohq.io.

## When this applies

**Explicit (Avo named):** "populate `Avo::Current.tenant`", "configure `config.tenancy`", "mount Avo under `/:tenant_id`", "scope Avo resources to the current account/team", "add an account switcher to Avo".

**Implicit (Rails-shaped):** "scope the admin per account / team / organization", "each customer should only see their own data in the admin", "make the admin multi-tenant", "add an account switcher", "mount the admin under `/:account_id`", "each client should only see their own records in the admin panel".

Pick the strategy from what the user describes:

- Tenant **remembered per session** and toggled with a switcher, URL unchanged: **session strategy** (the default).
- Tenant **in the URL** (`/42/resources/...`, deep links carry the tenant): **route strategy**.
- Tenant as a **subdomain** with row-level scoping: point at **Acts As Tenant** (special license; see Docs).

## Workflow

First confirm authentication is wired (`current_user` resolves; see **avo-authentication**), then read `config/initializers/avo.rb`, `config/routes.rb` and the tenant model's associations. In the examples the tenant model is `Account` and the user has `has_many :accounts`; substitute the app's real names.

### 1. Return the user's accounts

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.tenancy = {
    tenants: -> { current_user.accounts }
  }
end
```

- `tenants:` must return an **Active Record relation** of the accounts the current user may act for. It runs in the request with `current_user`, `params` and `request` available.
- Avo only ever looks a tenant up through this relation (`tenants.find_by(id: ...)`). An id from the session, the switcher or the URL that is not in it never resolves. That membership check is the whole security model, so never return `Account.all` for ordinary users.
- Order the relation when the default matters: a user with no stored pick lands on its first record.
- `title:` (default `:name`) is the method the switcher calls to label each account: `config.tenancy = {tenants: ..., title: :display_name}`.
- Super admins who may act for every account: make it an explicit branch, `-> { current_user.super_admin? ? Account.all : current_user.accounts }`. They still act for one account at a time.

That is the whole session-based setup. Avo then:

- stores the pick in the session together with the user who made it, so signing in as someone else (or impersonating) never inherits it;
- re-checks membership on every request and falls back to the user's first account when the stored one is gone;
- fails closed: a user with no accounts gets a "No account to show" page (`403`), never the admin with a `nil` tenant;
- renders the switcher at the bottom of the sidebar (hidden when the user has one account). Switching is a CSRF-protected `PATCH` to the engine's `switch_tenant` route, answers `404` for an id outside `tenants:`, clears saved filters and page numbers, does a full page load and lands on the current resource's index or the Avo root;
- emits `ActiveSupport::Notifications` event `switch_tenant.avo` with `user:`, `from:` and `to:` for audit logs.

### 2. Route strategy (tenant in the URL)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope "/:tenant_id" do
    mount_avo
  end
end
```

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.default_url_options = [:tenant_id]

  config.tenancy = {
    tenants: -> { current_user.accounts },
    strategy: :route
  }
end
```

Avo looks `params[:tenant_id]` up through `tenants:` and raises `ActiveRecord::RecordNotFound` (a `404`) when the user doesn't belong to it. No switcher renders in this mode. The segment must be named `tenant_id` and hold the account's primary key.

### 3. Scope the data

`config.tenancy` only resolves the tenant. Every resource holding tenant data must be scoped by `Avo::Current.tenant`, or every account still sees every record:

- **Policy scope** (authorization add-on): one place that covers index, show/edit, search and associations.

  ```ruby
  # app/policies/project_policy.rb
  class ProjectPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.where(account: Avo::Current.tenant)
      end
    end
  end
  ```

- **Resource queries** (Community): scope both the index and single-record lookups. `index_query` alone leaves another account's record reachable by its id.

  ```ruby
  # app/avo/resources/project.rb
  class Avo::Resources::Project < Avo::BaseResource
    self.index_query = -> { query.where(account: Avo::Current.tenant) }
    self.find_record_method = -> { query.where(account: Avo::Current.tenant).find(id) }
  end
  ```

- Or a model-level scope / `acts_as_tenant`.

Then write request specs that sign in as a user of account A and prove an account-B record is absent from the index, unreachable by id, and absent from global search.

### Subdomain / row-level (Acts As Tenant)

For subdomain-per-tenant or row-level scoping via the [`acts_as_tenant`](https://github.com/ErwinM/acts_as_tenant) gem, follow the **Acts As Tenant integration** guide (see Docs). More than one URL per app needs a special Avo license.

## Gotchas

- **Never write a tenant id from params straight into the session or `Avo::Current`.** `session[:tenant_id] = params[:id]` lets anyone change the id and read another customer's admin. Use `config.tenancy`; if the app truly needs a hand-rolled `before_action`, look the tenant up through `current_user.accounts.find_by(id: ...)`, re-check it on every request, bind it to the user, and render an error instead of continuing with `nil`.
- **Remove the old hand-rolled pieces when moving to `config.tenancy`.** A leftover `prepend_before_action :set_tenant` concern or `SwitchAccountsController` would run alongside Avo's and can overwrite `Avo::Current.tenant` from an unchecked id.
- **Setting the tenant is not filtering the data.** See step 3.
- **Turning tenancy on for an app whose users have no account yet locks them out** with the "No account to show" page. That is the fail-closed design; create memberships first.
- **Route strategy without `config.default_url_options = [:tenant_id]` breaks navigation**: every link Avo generates drops the segment.
- **Multiple tabs share one session.** A form opened under account A and submitted after switching to B in another tab is submitted under B. Scoped record lookups (step 3) keep updates from reaching A's records through B.
- **Verify before writing.** Confirm `config.tenancy`, its keys and `Avo::Current` against the docs or the installed Avo source rather than memory.

## Report

When done, tell the user:

- Which files you touched (full absolute paths): typically `config/initializers/avo.rb`, plus `config/routes.rb` for the route strategy, and the policies or resources you scoped.
- The strategy (session or route) and the `tenants:` relation that bounds what each user can reach.
- How the data is scoped (policy scope, resource queries, model scope) and which resources still read unscoped data, if any.
- Any hand-rolled tenant code you removed.
- Handoffs: **avo-authentication** if `current_user` isn't wired yet; the authorization docs (https://docs.avohq.io/4.0/authorization.md) to scope records with policies.
