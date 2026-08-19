---
name: avo-setup
description: Install Avo, mount it in `config/routes.rb`, authenticate the private gem server, and set the license key. Use when the user wants to install Avo, add an admin panel to a Rails app, mount the admin at a path/scope/nested path/subdomain (e.g. `/backoffice`, `admin.myapp.com`), add paid Avo add-on gems (`avo-dashboards`, `avo-dynamic_filters`, `avo-kanban`, …), fix a `403 Forbidden` pulling a private or paid Avo gem, can't bundle the paid gem, set the gem-server token on Heroku/Hatchbox/GitHub Actions/Docker/Kamal, deploy the admin when the gem won't install, add or wire a license key, fix an admin that says unlicensed or shows a license-timeout badge, or append custom routes inside the Avo engine.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — this skill installs `avo` plus any paid add-on gems
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Setup

Getting Avo into a Rails app is four moving parts: **install** the right gems, **authenticate** the private gem server if any are paid, **mount** the engine in `config/routes.rb`, and **license** it for production. Avo ships as a family of gems — the `avo` Community gem is free on rubygems.org; each paid feature is its own add-on gem (`avo-dashboards`, `avo-dynamic_filters`, `avo-kanban`, …) served from Avo's private server at [`packager.dev`](https://packager.dev) and needs a Gem Server Token to bundle. One `mount_avo` call in the routes file mounts Avo and every engine it registers, so a subdomain, a scope, or a nested path is a routing detail on that single call. This skill covers install → gem-server auth → mount → license, plus appending your own routes inside the engine. What each per-app knob in `config/initializers/avo.rb` does (`app_name`, `per_page`, `container_width`, …) belongs to the **avo-admin-config** skill; gating who can reach the admin by wrapping `mount_avo` in `authenticate :user do…end` is **avo-authentication**; deep license/gem-auth failure diagnosis is **avo-troubleshoot**.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Installation: https://docs.avohq.io/4.0/installation.md
- Routing / mounting: https://docs.avohq.io/4.0/routing.md
- Gem server authentication: https://docs.avohq.io/4.0/gem-server-authentication.md
- Licensing: https://docs.avohq.io/4.0/licensing.md
- License troubleshooting: https://docs.avohq.io/4.0/license-troubleshooting.md

## When this applies

**Explicit (Avo named):** "install Avo", "add the Avo gem", "add an Avo add-on gem (`avo-dashboards`, `avo-kanban`, …)", "mount Avo at `/admin`", "put Avo on a subdomain", "set the Avo license key", "add my Gem Server Token", "`BUNDLE_PACKAGER__DEV`", "append a route inside the Avo engine".

**Implicit (Rails-shaped, no mention of Avo):** "add an admin panel to my Rails app", "mount the admin at `/backoffice`", "put the admin on `admin.myapp.com`", "the admin should live under `/uk/admin`", "`403 Forbidden` pulling a private gem", "can't bundle the paid gem", "the paid gem won't install on Heroku/Kamal", "set up the gem token in CI/Docker", "deploy the admin and the gem is missing", "the admin says it's unlicensed", "there's a license-timeout badge in the admin", "I want an extra route in the admin's router".

## Workflow

### 1. Check requirements first

Avo needs, in the target app:

- Rails **>= 6.1**, Ruby **>= 3.2** (the gemspec enforces it — an older Ruby fails at `bundle install`).
- `config.api_only` **= false** (an API-only app has no views/session/flash for Avo to render — see the docs map's api-only guide).
- `propshaft` **or** `sprockets` in the Gemfile.
- A `secret_key_base` (from `ENV["SECRET_KEY_BASE"]`, credentials, or secrets).
- **Zeitwerk** autoloading (`config.load_defaults 6.1`+). An app upgraded from Rails 5 must switch off the classic autoloader.

If any are missing, fix that before installing — otherwise the install "succeeds" but the admin won't boot.

### 2. Pick the gems and add them to the Gemfile

The `avo` Community gem is free and comes from rubygems.org. It covers resources, most fields, sorting, filtering, actions, associations, appearance, and i18n — about 70% of Avo. Each advanced feature is its own paid **add-on gem** from the private server, so a license only pulls in what it includes.

Community only — nothing private, no token needed:

```ruby
# Gemfile
gem "avo", ">= 4.0.0"
```

Paid add-ons — declare the gems included in the license inside a `source` block pointing at the private server:

```ruby
# Gemfile
gem "avo", ">= 4.0.0"

source "https://packager.dev/avo-hq/" do
  # the add-ons on the license, e.g.
  gem "avo-dashboards", ">= 4.0.0"
  gem "avo-menu", ">= 4.0.0"
  gem "avo-dynamic_filters", ">= 4.0.0"
  gem "avo-authorization", ">= 4.0.0"
end
```

Other add-on gems (`avo-advanced_search`, `avo-record_reordering`, `avo-kanban`, `avo-collaboration`, `avo-forms`, `avo-nested`, …) go in the same block. All paid gems come from `packager.dev` and need the token from step 3 to `bundle install`.

To ship the app to environments **without** the paid gems, move them to an optional group and bundle without it:

```ruby
# Gemfile
gem "avo"

group :avo, optional: true do
  source "https://packager.dev/avo-hq/" do
    gem "avo-dashboards", "~> 4.0"
  end
end
```

```bash
RAILS_GROUPS=avo BUNDLE_WITH=avo bundle install
```

### 3. Authenticate the private gem server (paid add-ons only)

The token is the **Gem Server Token** from https://avohq.io/dashboard. It authenticates bundler to `packager.dev`. Skip this step entirely for Community.

**Local machine** — store it in bundler's global config (bundler picks it up automatically, no Gemfile change):

```bash
bundle config set --global https://packager.dev/avo-hq/ xxx
```

**Servers & CI** — expose it as the `BUNDLE_PACKAGER__DEV` environment variable (bundler maps this env var to the `packager.dev` source):

```bash
export BUNDLE_PACKAGER__DEV=xxx
# or one-shot:
BUNDLE_PACKAGER__DEV=xxx bundle install
```

Per host:

- **Heroku:** `heroku config:set BUNDLE_PACKAGER__DEV=xxx`
- **Hatchbox:** add `BUNDLE_PACKAGER__DEV` in the app's Environment tab.
- **GitHub Actions:** add a repo secret named `BUNDLE_PACKAGER__DEV`, then surface it in the workflow with `env: { BUNDLE_PACKAGER__DEV: ${{ secrets.BUNDLE_PACKAGER__DEV }} }`.
- **Docker:** `ARG BUNDLE_PACKAGER__DEV` + `ENV BUNDLE_PACKAGER__DEV=$BUNDLE_PACKAGER__DEV` before `bundle install`, then `docker build --build-arg BUNDLE_PACKAGER__DEV=$BUNDLE_PACKAGER__DEV`.
- **Kamal:** list `BUNDLE_PACKAGER__DEV` under `builder.secrets` in `deploy.yml`, put the value in `.kamal/secrets`, and in the Dockerfile run `RUN --mount=type=secret,id=BUNDLE_PACKAGER__DEV BUNDLE_PACKAGER__DEV=$(cat /run/secrets/BUNDLE_PACKAGER__DEV) bundle install`.

Then `bundle install`.

### 4. Run the install generator

```bash
bin/rails generate avo:install
```

This generates `config/initializers/avo.rb`, adds `mount_avo` to `config/routes.rb` (mounting under `/avo` by default), and — if a `User` (or `Account`) model exists — generates a first resource. Fastest path for a brand-new setup is the one-command app template, which runs every install step:

```bash
bin/rails app:template LOCATION='https://avohq.io/app-template'
```

**Installing from GitHub** (not rubygems) means precompiled assets aren't shipped — you must compile them yourself and hook that into deploys:

```bash
rake avo:build-assets
```

```ruby
# Rakefile — run avo:build-assets whenever assets are precompiled
Rake::Task["assets:precompile"].enhance do
  Rake::Task["avo:build-assets"].execute
end
```

(If your deploy has no `assets:precompile` step, enhance a step you do run, e.g. `db:migrate`.)

### 5. Mount it where you want

`mount_avo` forwards options straight to Rails' `mount`, and its `at:` defaults to `config.root_path`. Pick the shape:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount_avo                          # default: config.root_path (/avo)
  mount_avo at: "backoffice"         # → /backoffice
end
```

Under a scope (e.g. localization):

```ruby
scope ":locale" do
  mount_avo
end
```

(A `:locale` scope also needs `config.default_url_options` set — see the routing docs.)

On a subdomain — `admin.myapp.com`:

```ruby
constraints subdomain: "admin" do
  mount_avo at: "/"
end
```

Under a **nested path** — `/uk/admin` — three things have to line up:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope :uk do
    scope :admin do
      get "dashboard", to: "avo/tools#dashboard"  # custom tools FIRST
    end
    mount_avo   # engine mounted LAST, after custom-tool routes
  end
end
```

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.root_path = "/admin"            # ONLY the last segment — not "/uk/admin"
  config.home_path = "/uk/admin/dashboard"  # other paths use the FULL path
end
```

Served under a `map` prefix in `config.ru` — tell Avo the prefix so it builds correct URLs:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.prefix_path = "/internal"
end
```

To restrict who can reach the admin, wrap `mount_avo` in `authenticate :user do…end` — that's the **avo-authentication** skill, not this one.

### 6. Add the license key (production)

Community needs no key. For paid add-ons, drop the key into the initializer (an env var keeps it out of source control):

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.license_key = ENV["AVO_LICENSE_KEY"]
end
```

A license authorizes **one app, one production URL** (`Rails.env.production?`). Non-production environments — development, staging, test, QA — need no extra license. To hide the "license request timed out" badge, set `config.display_license_request_timeout_error = false`.

Verify at the **status page**: `https://yourapp.com/<mount-path>/avo_private/status` (e.g. `.../avo/avo_private/status` or `.../admin/avo_private/status`). It shows whether the license authenticated and what the checking server returned; the key is masked unless you set `config.exclude_from_status = []`. The viewing user must be an Avo admin. Deep failure diagnosis (unlicensed after deploy, timeouts, test-suite blocking the check host) is the **avo-troubleshoot** skill.

**Trials are full licenses.** Every add-on a trial covers behaves exactly as it does on a paid license while the trial runs — nothing is gated or degraded. The **Avo Status** indicator in the sidebar footer is green when all is well, **amber** when a trial needs attention, and orange when the license is invalid. Amber is not a failure; it means either no payment method is on file (access stops on the trial's end date) or the subscription behind the trial was cancelled (access stops on the cancellation date, and adding a payment method won't change that — the subscription has to be resumed). Both are fixed on https://avohq.io/licenses, and the status page names which one applies. Avo caches the license response between checks, so press **Refresh license** on the status page afterwards or the app keeps showing the older billing state. Trial state needs `avo-licensing` **4.0.10+**; the amber indicator needs Avo **4.0.20+** (an older Avo renders an uncolored dot rather than breaking).

### 7. (Optional) Append your own routes inside the engine

Add custom controllers/actions to Avo's own router — open the engine's routes after `mount_avo`:

```ruby
# config/routes.rb
if defined? ::Avo
  Avo::Engine.routes.draw do
    put "switch_accounts/:id", to: "switch_accounts#update", as: :switch_account

    scope :resources do
      get "courses/cities", to: "courses#cities"   # extra route on a resource controller
    end
  end
end
```

```ruby
# app/controllers/avo/switch_accounts_controller.rb
class Avo::SwitchAccountsController < Avo::ApplicationController
  def update
    session[:tenant_id] = params[:id]
    redirect_back fallback_location: root_path
  end
end
```

## Key options

| Option / call | Does | Tiny example |
| --- | --- | --- |
| `mount_avo` | Mount Avo + all engines in `routes.rb` | `mount_avo at: "backoffice"` |
| `at:` | Mount path (forwards to Rails `mount`) | `mount_avo at: "admin"` |
| `config.root_path` | Avo's root path — **last segment only** when nested | `config.root_path = "/admin"` |
| `config.prefix_path` | Prefix when served under a `config.ru` `map` block | `config.prefix_path = "/internal"` |
| `source "https://packager.dev/avo-hq/"` | Gemfile block that scopes paid gems to the private server | wrap `gem "avo-dashboards"` |
| `BUNDLE_PACKAGER__DEV` | Gem-server token env var bundler uses for `packager.dev` | `export BUNDLE_PACKAGER__DEV=xxx` |
| `bundle config set --global …` | Store the token locally without touching the Gemfile | `… https://packager.dev/avo-hq/ xxx` |
| `config.license_key` | Production license key | `config.license_key = ENV["AVO_LICENSE_KEY"]` |
| `config.display_license_request_timeout_error` | Hide the license-timeout badge | `= false` |
| `config.exclude_from_status` | Reveal masked fields on the status page | `config.exclude_from_status = []` |
| `rake avo:build-assets` | Compile assets (required for GitHub installs) | hook into `assets:precompile` |
| `Avo::Engine.routes.draw` | Append custom routes inside Avo's router | see step 7 |

## Gotchas

- **`.env` does NOT work for the gem-server token.** Bundler doesn't load `.env` files, so a `BUNDLE_PACKAGER__DEV` line there is ignored and `bundle install` fails with `403 Forbidden`. Use a real exported env var or the host's secrets mechanism (or `bundle config` locally).
- **`403 Forbidden` in a sandboxed/cloud env is usually the network, not the token.** In the Claude Code cloud environment, Cursor background agents, or any setup with restricted egress, a correctly-set token still 403s because a network allowlist is blocking `packager.dev`. Add `packager.dev` to the allowed hosts and re-run `bundle install` — don't churn on the token.
- **Nested mount = two easy mistakes.** For `/uk/admin`: `config.root_path` must be **only the last segment** (`/admin`, never `/uk/admin`), and `mount_avo` must be the **last** thing in the scope, after any custom-tool routes — otherwise the engine swallows them.
- **`api_only` must be `false`.** An API-only app has no session/flash/views; Avo can't render. Flip it (or follow the api-only guide) before installing.
- **GitHub installs don't ship assets.** Install from GitHub and you must `rake avo:build-assets` yourself and hook it into `assets:precompile`, or the admin renders unstyled/broken in production.
- **One license per production URL.** A key authorizes a single app on a single production URL; staging/dev/test don't consume licenses. A second production URL needs its own license.
- **Add-on gems must sit inside the `packager.dev` `source` block** — that's where the private gems resolve from; `avo` itself stays outside it (rubygems.org).
- **Verify before writing.** Option and path names drift between versions — check the docs URLs above or the app's installed Avo source rather than trusting memory.

## Report

When done, tell the user:

- Which files you touched (full paths): `Gemfile`, `config/routes.rb`, `config/initializers/avo.rb`, and any Rakefile/CI/Dockerfile edits — plus the generator command(s) run.
- The **gems** installed (`avo` alone vs which paid add-on gems) and, for paid, **where** the gem-server token lives (bundler config, host env var, CI secret) — never echo the token value itself.
- The **mount** shape and resulting URL (path / scope / subdomain / nested), and any `root_path` / `prefix_path` you set to match it.
- Whether the **license key** is wired (and via which env var), and the **status-page URL** to confirm it in production.
- Any custom engine routes you appended.
- Next steps: run `bundle install`, generate a first resource (**avo-resources**), gate access to the admin (**avo-authentication**) and set up authorization, tune per-app behavior in the initializer (**avo-admin-config**), and — if the gem won't bundle or the license won't validate — hand off to **avo-troubleshoot**.
