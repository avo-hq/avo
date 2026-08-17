---
name: avo-troubleshoot
description: >-
  Use when an Avo (Rails admin) app is broken or behaving unexpectedly: a
  field/resource/filter/action that isn't showing; the admin returning 500 or 404; `bundle install`
  failing to fetch `avo`/`avo-*` gems or 401 from packager.dev; the license not validating or the
  status page erroring; authorization suddenly denying everything; tests failing after upgrading
  Avo; `WebMock::NetConnectNotAllowedError` for clerk-1/clerk-2.avohq.io; exploded/missing icons
  after an upgrade. Also "why is my Avo field not showing", "my admin broke after bundle update".
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Troubleshoot a broken Avo app

Avo is a Rails admin framework. When an app that uses it breaks — a page 500s, a field vanishes, `bundle install` fails, authorization locks everyone out — the developer usually arrives with a **symptom**, not a feature name. This skill is organized that way: match the symptom, find the root cause, apply the fix.

Most "Avo is broken" reports are **not Avo bugs**. They're an app-level config issue (a missing policy method, an `if/else` in `def fields`, a model validation, an unset env var) that Avo surfaces. Your first job is to tell those apart from a genuine Avo core bug — see [First moves](#first-moves). Don't reach for framework escape hatches (least of all security ones) when the real fix is in the app.

**Docs** (fetch on demand — confirm exact option names against the page or the installed gem, never memory):
- Docs map / index: https://docs.avohq.io/4.0/docs-map.md
- License troubleshooting + status page: https://docs.avohq.io/4.0/license-troubleshooting.md
- Testing (license host allow-list): https://docs.avohq.io/4.0/testing.md
- Custom errors / why a save fails: https://docs.avohq.io/4.0/custom-errors.md
- FAQ (URL helpers, hide buttons, filter predicate error): https://docs.avohq.io/4.0/faq.md
- Best practices (`if/else` in `def fields`): https://docs.avohq.io/4.0/guides/best-practices.md
- 404 handling: https://docs.avohq.io/4.0/guides/handle-404-responses-in-avo.md
- Gem server auth (packager.dev token): https://docs.avohq.io/4.0/gem-server-authentication.md
- Authorization (`explicit_authorization`): https://docs.avohq.io/4.0/authorization.md
- v3 → v4 upgrade (source of truth for renames): https://docs.avohq.io/4.0/avo-3-avo-4-upgrade.md
- Technical support / reproduction repo: https://docs.avohq.io/4.0/technical-support.md

---

## First moves

Before changing anything, establish **whose bug this is** and **what actually changed**.

### 1. Isolate — is this Avo or your app?

The single most useful question. Reproduce the symptom in a clean, generated app:

```bash
rails new -m https://avo.cool/new.rb APP_NAME          # Community
rails new -m https://avo.cool/new-pro.rb APP_NAME      # + Pro feature gems
rails new -m https://avo.cool/new-advanced.rb APP_NAME # + Advanced feature gems
```

- **Reproduces in the clean app** → likely an Avo core bug. Point the user at existing issues (search https://github.com/avo-hq/avo/issues) and, if new, https://avo.cool/new-issue — a fresh repro app is exactly what the team needs.
- **Does not reproduce** → it's your app's config/data/other gems. Fix it here; don't file it as an Avo bug.

### 2. Scope discipline

Avo's OSS support covers Avo and the `avo-*` libraries — **not** app-specific issues (config unrelated to Avo, conflicts with other gems, deployment/infra, your data, integrations). Keep the line clear when you report back: "this is your app's `X`, fixed here" vs. "this is Avo core, here's the issue to follow." Don't send someone to GitHub for something that lives in their `def fields`.

### 3. Verify against the installed source, not memory

Option names changed between v3 and v4 (see the [upgrade section](#v3--v4-upgrade)). Before recommending a renamed/removed option, confirm it exists in the **version actually installed**:

```bash
bundle show avo          # prints the gem's path — grep it for the option
bundle show avo-dashboards   # each add-on lives in its own gem in v4
grep -rn "explicit_authorization" "$(bundle show avo)/lib"
```

### 4. Two reflexes that resolve a surprising number of reports

- **Restart the server** after editing `config/initializers/avo.rb`, adding a Pundit policy, or setting `current_user_method`. Initializer and auth wiring changes don't hot-reload.
- **Never silently flip a security default to "fix" a symptom.** Setting `config.explicit_authorization = false` will make hidden fields/actions reappear — because it re-opens the insecure v3 default and authorizes everything with a missing policy. The fix is the missing policy method, not disabling the check. Only revert the default deliberately, with the user's informed sign-off.

---

## Symptom → diagnosis

| Symptom | Most likely cause | Jump |
| --- | --- | --- |
| A field / resource / action / filter isn't showing | `if/else` in `def fields`, or a missing policy under v4's stricter default, or auth not wired, or no server restart | [↓](#a-field--resource--action--filter-isnt-showing) |
| Authorization suddenly denies everything (after upgrade) | `explicit_authorization` default flipped `false → true` in v4 | [↓](#authorization-suddenly-denies-everything) |
| 500 on save / create / update / destroy | A **model** validation or exception surfaced by Avo — usually not an Avo bug | [↓](#500-on-save--create--update--destroy) |
| 404 in the admin | `ActiveRecord::RecordNotFound`; Avo defers to Rails' 404 unless you rescue it | [↓](#404-in-the-admin) |
| `No valid predicate for combinator` when filtering | `config.ignore_unknown_conditions` is `false` | [↓](#no-valid-predicate-for-combinator-when-filtering) |
| `undefined method 'xxx_path'` inside an Avo block | Avo is a Rails engine — needs `main_app.` prefix | [↓](#url-helpers-blow-up-inside-avo-blocks) |
| License won't validate / status page errors | Key not set on the server; check the status page | [↓](#license-wont-validate) |
| Tests fail after adding/upgrading Avo (`WebMock::NetConnectNotAllowedError`) | v4's outbound license check to `clerk-*.avohq.io` is blocked | [↓](#tests-fail-after-adding-or-upgrading-avo) |
| `bundle install` can't fetch `avo-*` / 401 / 403 | packager.dev token not seen by Bundler, or a blocked host in sandboxes | [↓](#bundle-install-cant-fetch-avo--gems) |
| Exploded / missing icons, or other odd behavior after a version bump | Silent v4 behavior changes and renames | [↓](#v3--v4-upgrade) |

### A field / resource / action / filter isn't showing

Work through these in order — the first two are by far the most common.

1. **`if/else` inside `def fields`.** Avo needs the *complete* field list on every request to wire up filters, permitted params, and the UI. A conditional that adds `field :a` in one branch and `field :b` in another means Avo only ever sees one of them — so filters go missing, params aren't permitted, and fields disappear. **Fix:** declare every field unconditionally and gate it with `visible:`.

   ```ruby
   # Wrong — the list is [special] or [regular], never both
   def fields
     if params[:special_case].present?
       field :special_field, as: :text
     else
       field :regular_field, as: :text
     end
   end

   # Right — both are always declared; visibility is computed
   def fields
     field :special_field, as: :text, visible: -> { params[:special_case].present? }
     field :regular_field, as: :text, visible: -> { params[:special_case].blank? }
   end
   ```

   → `guides/best-practices.html`

2. **A missing policy under v4's stricter default.** In Avo 4, `config.explicit_authorization` defaults to `true`: a resource/field/action whose policy **class or method** is missing is **denied silently** — no error, it just doesn't render. **Fix:** add the policy method for what's hidden, don't disable the check. Button/field visibility maps to policy methods:

   - Show → `show?`, Edit → `edit?`, Delete → `destroy?`, Index → `index?`
   - Upload/Download/Delete attachment → `upload_{FIELD}?` / `download_{FIELD}?` / `delete_{FIELD}?`
   - Attach/Detach → `attach_{association}?` / `detach_{association}?` (e.g. `attach_posts?`)

   → `authorization.html`, `faq.html`

3. **Authorization not wired.** Symptoms also appear when the plumbing is incomplete: the Authorization add-on isn't installed, `current_user_method` isn't set, the Pundit policy doesn't exist, or the server wasn't restarted after any of those. → `faq.html` ("The authorization features are not working")

4. **Server not restarted** after editing the initializer or adding a policy. Restart and re-check before digging deeper.

### Authorization suddenly denies everything

Almost always a v3 → v4 upgrade side effect: `config.explicit_authorization` flipped from `false` to `true`. Under v3, a missing policy method fell back to **authorized**; under v4 it falls back to **denied**. Incomplete policies that "worked" on v3 now hide records, fields, and actions.

**Fix:** audit your policies and add the methods that are now required (see the mapping above). The escape hatch `config.explicit_authorization = false` restores the old behavior, but it re-opens the insecure default across the whole app — treat it as a deliberate, user-approved choice, not a quick unblock. → `authorization.html`, upgrade section below.

### 500 on save / create / update / destroy

Usually **not** an Avo bug — it's your model refusing the write, surfaced by Avo:

- Any `errors.add(...)` from a `validate` method or `validates` rule **aborts** the create/update. Attribute errors render inline under the field; `:base` errors (and errors for attributes with no field on the form) render as an alert banner.
- Exceptions raised *outside* validation during save/destroy (a foreign-key constraint on delete, a failing `after_save`) are **caught** and shown as a `:base` alert — so this fails gracefully rather than 500-ing.
- Developers additionally see the full backtrace in the alert; this is gated on `Avo::Current.user_is_developer?`, so end users only see the message.

**So:** check the model's validations and callbacks first. If you're seeing an actual unhandled 500 (not the alert), reproduce in a clean app before suspecting Avo. → `custom-errors.html`

### 404 in the admin

When Rails raises `ActiveRecord::RecordNotFound`, Avo lets Rails render its default 404 page. To handle it yourself (e.g. redirect to the admin root), eject the application controller and rescue the exception:

```bash
rails generate avo:eject --controller application_controller
```

```ruby
class Avo::ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: -> {
    redirect_to Avo.configuration.root_path, notice: t("avo.no_item_found")
  }
end
```

→ `guides/handle-404-responses-in-avo.html`

### `No valid predicate for combinator` when filtering

The app has `config.ignore_unknown_conditions = false`. Set it to `true`:

```ruby
# config/initializers/avo.rb
config.ignore_unknown_conditions = true
```

→ `faq.html`

### URL helpers blow up inside Avo blocks

`undefined method 'partner_home_url'` (or similar) inside a field block, computed field, or any Avo DSL. Avo runs that code inside its own Rails **engine**, so your main app's route helpers aren't in scope. Prefix them with `main_app.`:

```ruby
field :partner_home, as: :text, as_html: true do
  link_to "Partner", main_app.partner_home_url(record) # not partner_home_url(record)
end
```

Prefer Rails route helpers (with `main_app.` / `avo.`) over hardcoded paths everywhere. → `faq.html`

### License won't validate

1. **Key not set on the server.** The most frequent cause. Confirm `config.license_key = ENV["AVO_LICENSE_KEY"]` and that the env var is actually present in **production** (not just locally).
2. **Check the status page.** Every Avo app exposes `https://yourapp.com/<mount>/avo_private/status` — e.g. `/admin/avo_private/status` if you mounted Avo at `admin`. It shows whether the license authenticated and the raw response from the check server. The viewing user must be an Avo admin.
3. **Key hidden on the status page.** The key is redacted by default; set `exclude_from_status = []` in the initializer if you need to see it while debugging.
4. **An amber sidebar indicator is not a license failure.** Green is fine, orange is invalid, **amber is a running trial that needs attention** — either no payment method is on file, or the subscription behind the trial was cancelled. Access continues until the date the status page reports, and the page names which of the two applies. Fix it at [avohq.io/licenses](https://avohq.io/licenses), then press **Refresh license** on the status page: Avo caches the license response, so the app can keep showing older billing state than avohq.io until it re-checks.

→ `license-troubleshooting.html`

### Tests fail after adding or upgrading Avo

Error looks like:

```
WebMock::NetConnectNotAllowedError:
  Real HTTP connections are disabled. Unregistered request:
  POST https://clerk-1.avohq.io/api/v4/licenses/check with body '...'
```

**Cause:** Avo 4 verifies the license via an outbound request to `clerk-1.avohq.io` (falling back to `clerk-2.avohq.io`), and it runs in **every** environment, including `test`. Avo 3 didn't make this request, so a suite that passed on v3 can start failing the moment you upgrade. WebMock/VCR `disable_net_connect!` blocks it.

**Fix:** add the two hosts to your **existing** allow list — don't replace the call and lose your other options:

```ruby
# spec/rails_helper.rb, spec/spec_helper.rb, or test/test_helper.rb
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["clerk-1.avohq.io", "clerk-2.avohq.io"] # add to whatever is already here
)
```

VCR equivalent:

```ruby
VCR.configure do |config|
  config.ignore_hosts "clerk-1.avohq.io", "clerk-2.avohq.io"
end
```

Only needed if you explicitly disable outbound connections in tests. → `testing.html`, `license-troubleshooting.html`

### `bundle install` can't fetch `avo-*` gems

Paid add-on gems are served from `packager.dev` and need a **Gem Server Token** that Bundler can see.

- **401 Unauthorized** → Bundler doesn't have the token. Set it as an environment variable Bundler reads, or in the global bundle config:

  ```bash
  export BUNDLE_PACKAGER__DEV=xxx                          # server / CI
  bundle config set --global https://packager.dev/avo-hq/ xxx  # local dev
  ```

- **`.env` does not work.** Bundler does not load `.env`, so putting the token there silently fails. Use a real environment variable (via `export`, the host's env settings, CI secrets, or a Docker/Kamal build secret).
- **403 Forbidden inside a sandbox / cloud agent** (Claude Code cloud, Cursor background agents, restricted egress). If the token *is* set correctly, a 403 usually means a **network allowlist is blocking `packager.dev`**, not bad auth. Add `packager.dev` to the environment's allowed hosts and retry.
- **v4 gem split.** In Avo 4 each feature ships as its own add-on gem (`avo-dashboards`, `avo-menu`, `avo-advanced_search`, `avo-authorization`, `avo-record_reordering`, `avo-dynamic_filters`, `avo-nested`, …); the legacy v3 bundle gems (`avo-pro`, `avo-advanced`) are gone. If a feature vanished after upgrading, you likely need to add its specific gem. See the upgrade section.

→ `gem-server-authentication.html`

---

## v3 → v4 upgrade

If the breakage started right after a version bump, it's probably one of Avo 4's **silent behavior changes** (passes tests, changes runtime) or a **rename** (option removed/renamed). The canonical, always-current source is https://docs.avohq.io/4.0/avo-3-avo-4-upgrade.md — fetch it before recommending any rename.

### Drive the upgrade with this agent prompt

For a full, methodical v3 → v4 upgrade, hand this prompt to a coding agent working **in the user's app** (it's the upgrade guide's own embedded prompt — reproduced here so you can run it directly):

```
Upgrade this Avo 3 app to Avo 4 using https://docs.avohq.io/4.0/avo-3-avo-4-upgrade.md as the source of truth. You may run shell commands (grep, bundle, the test suite, git) without asking each time — but ask before anything destructive or ambiguous.

Setup
- Confirm all incremental Avo 3 upgrades are applied up to the current version (https://docs.avohq.io/3.0/avo-2-avo-3-upgrade.html). If not, stop and tell me.
- Create a new branch. Run the test suite to capture a baseline; if it's already red, stop and tell me.
- Commit after each chapter, with the chapter name in the message.

Inventory before editing
- For each chapter, grep the codebase for the APIs it touches BEFORE changing anything (e.g. main_panel, no_confirmation, cluster/row, profile_photo, cover_photo, branding, with_tools, result_path, params[:via_association], `size:` in pagination, PanelComponent, the renamed view-type components, etc.).
- Many chapters won't apply. Mark each APPLIES / NOT USED / NEEDS REVIEW. Never apply a change for an API the app doesn't use.

Gems first
- Update the Gemfile to >= 4.0.0 for `avo` and every `avo-*` gem in use (check for avo-nested, avo-rhino_field, avo-dynamic_filters, etc.), move private gems under the packager.dev source block, run bundle, and boot the app before touching app code.
- Nested forms now need the separate avo-nested gem — add it if has_many/has_one/habtm use `nested`.

Apply, per chapter
- Make the change, boot the app, re-run tests. Prefer Rails route helpers over hardcoded paths.
- When a chapter links a sub-page (appearance, global search, badge, etc.), fetch and follow it rather than guessing the new API.

⚠️ Silent behavior changes — these pass tests but change runtime behavior, flag each explicitly:
- `explicit_authorization` now defaults to true → actions/fields/records with a missing policy method are now DENIED. Audit policies.
- Action `no_confirmation` → `confirmation`, default flipped (modal now shows by default).
- `params[:via_association]` is gone → any `== 'has_many'` branch silently falls through to else. Migrate to `search_type`.
- Dynamic filters `always_expanded` now defaults to true.

Output
- Produce avo-3-to-4-upgrade.md: one checklist item per chapter with status (applied / skipped / needs-review) and what changed.
- End with "Manual verification needed" — things tests can't catch: missing/exploded icons (Heroicons→Tabler), avatar/cover rendering, custom CSS referencing old --avo-* variables or Algolia .aa-* selectors, appearance/branding visuals.

Don't invent APIs — if the guide doesn't cover a case, stop and ask.
```

### Silent behavior changes (green tests, different runtime) — check these first

These are the ones that break a "working" app without any error:

- **`explicit_authorization` now defaults to `true`** — missing policy methods now **deny**. → [Authorization suddenly denies everything](#authorization-suddenly-denies-everything).
- **Action `no_confirmation` → `confirmation`, default flipped.** v3 skipped the modal by default; v4 **shows** it by default. `self.no_confirmation = true` becomes `self.confirmation = false`.
- **`params[:via_association]` removed.** The v4 searchable-association picker no longer sets it, so any `if params[:via_association] == 'has_many'` branch silently falls through to `else` (wrong scope, no error). Migrate to the injected `search_type` local (`:global` / `:resource` / `:association` / `:kanban`). `params[:for_kanban_board]` is likewise gone → `search_type == :kanban`.
- **Dynamic filters `always_expanded` now defaults to `true`** — the filter bar shows expanded and the toggle button is hidden. Set `Avo::DynamicFilters.configure { |c| c.always_expanded = false }` to restore.

### Renamed / removed at a glance

| Avo 3 | Avo 4 | Notes |
| --- | --- | --- |
| `no_confirmation = true` | `confirmation = false` | default flipped (see above) |
| `main_panel do` | `card do` / `panel do` (+ `header`) | `main_panel` removed; wrapping depends on sidebar/preceding content |
| `Avo::PanelComponent` | `Avo::UI::PanelComponent` | also `with_tools` → `with_controls`; wrap field lists in `ui.description_list` |
| `field_container` helper | `ui.description_list` | removed; a plain `<div>` is not a safe swap |
| `cluster` / `row` blocks | `field ..., width: 50` | removed; adjacent fields with `width < 100` sit on one row |
| pagination `size:` | `slots:` | |
| `config.branding` | `config.appearance` | `colors:` hash gone (use `accent:` / `accent_colors:`); CSS vars renamed (`--avo-color-*` → `--color-*`) |
| Heroicons (`heroicons/...`) | Tabler (`tabler/outline/...`) | **"exploded" UI = missing icons.** See the `avo-menu-icons` skill and PR avo-hq/avo#4342 |
| `self.profile_photo` | `self.avatar` | now used across Show/Edit/breadcrumbs |
| `self.cover_photo` | `self.cover` | |
| `Avo::Index::ResourceTableComponent` / `ResourceMapComponent` | `Avo::ViewTypes::TableComponent` / `MapComponent` | update `self.components` keys |
| `config.disabled_features = [:global_search]` | `config.global_search = { enabled: false }` | |
| `config.full_width_index_view = true` | `config.container_width = { index: :full }` | |
| `avo-pro` / `avo-advanced` (legacy v3 bundles) | individual add-on gems | see the [gem split](#bundle-install-cant-fetch-avo--gems) |

"Exploded" layout, blank avatars/covers, or off colors after an upgrade are the **manual-verification** items — tests won't catch them. Check icons (Heroicons → Tabler), avatar/cover rendering, and any custom CSS referencing old `--avo-*` variables or Algolia `.aa-*` selectors (the searchable-association picker and global search were rewritten without Algolia).

---

## Report

When you finish, tell the user plainly:

1. **Symptom → root cause → fix.** What broke, why, and exactly what you changed (file + option).
2. **Whose bug it was.** App config/data (fixed here) vs. Avo core (searched issues; if new, share https://avo.cool/new-issue and note that a repro from `rails new -m https://avo.cool/new.rb` is what the team needs). Don't blur the line.
3. **Security note, if relevant.** If authorization was involved, confirm you added the missing policy method rather than disabling `explicit_authorization` — and if the user insists on the escape hatch, say plainly that it re-opens the insecure default app-wide.
4. **Manual verification needed.** Anything tests can't confirm — exploded/missing icons, avatar/cover rendering, appearance/branding visuals, custom CSS on renamed variables — as an explicit checklist.
5. **Restart reminder** if the fix touched the initializer, a policy, or auth wiring.
