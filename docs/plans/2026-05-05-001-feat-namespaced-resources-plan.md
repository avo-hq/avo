---
title: "feat: Support Namespaced Resources"
type: feat
status: completed
date: 2026-05-05
origin: docs/brainstorms/2026-05-04-namespaced-resources-requirements.md
---

# feat: Support Namespaced Resources

## Overview

Avo resources currently require a flat class name under `Avo::Resources::`. Models with Ruby namespaces (e.g., `Accounts::Invoice`) must use a flattened resource name and manually declare `self.model_class`. This plan enables namespaced resource classes (`Avo::Resources::Accounts::Invoice`) that auto-resolve to their model, live in matching subdirectories, and serve all URLs through a consistent nested path (`/avo/resources/accounts/invoices/`).

## Problem Frame

The core problem is that `class_name` in `Avo::Resources::Base` uses `to_s.demodulize`, which strips all namespace segments except the last. `Avo::Resources::Accounts::Invoice` resolves to `"Invoice"`, not `"Accounts::Invoice"`, breaking model auto-resolution and preventing natural file structure. Downstream methods — `route_key`, `translation_key`, `file_hash`, URL helpers, and routing — all derive from this single point.

Additionally, the shared wildcard routes in `config/routes.rb` (`/:resource_name` segments) only capture a single path segment, preventing namespaced resources from getting consistent nested URLs across CRUD, actions, and associations. The fix requires migrating those routes into per-resource dynamic route generation.

See origin: `docs/brainstorms/2026-05-04-namespaced-resources-requirements.md`

## Requirements Trace

- R1. `Avo::Resources::Accounts::Invoice` auto-resolves to `Accounts::Invoice` model without `self.model_class`
- R2. Explicit `self.model_class` overrides continue to take priority
- R3. Flat resource classes (`Avo::Resources::User`) are completely unaffected
- R4. Namespaced resource lives at `app/avo/resources/accounts/invoice.rb`
- R5–R6. Generator creates correct file and skips `self.model_class` injection for namespaced resources
- R7. `file_hash` works for files in subdirectories
- R8–R9. All URLs use nested path (`/avo/resources/accounts/invoices/`, actions, associations)
- R10. Flat resources keep their current flat URLs
- R11–R13. Dynamic routes produce correct named helpers; URL helpers construct correct URLs
- R14. `get_resource_by_controller_name` resolves multi-segment resource identifiers
- R15. Existing `self.model_class` workaround resources continue to work unchanged
- R16–R17. Namespaced controller (`Avo::Accounts::InvoicesController`) is generated; dynamic routes specify it

## Scope Boundaries

- Sidebar navigation grouping for namespaced resources is out of scope
- STI support is unchanged
- `Avo.configuration.resources` manual registration format is unchanged
- Arbitrary nesting depth works by convention; no depth limit is imposed
- The `avo_api` scope routes (`/:resource_name/search`, `/resources/:resource_name/:id/attachments/`) and the standalone `/:resource_name/:field_id/distribution_chart` route keep the single-segment wildcard form using `route_key` (underscore-joined); these are internal API/AJAX calls not visible in the browser URL bar

## Context & Research

### Relevant Code and Patterns

**Root of the problem:**
- `lib/avo/resources/base.rb:177` — `class_name`: `to_s.demodulize` → must change to `to_s.delete_prefix("Avo::Resources::")`
- `lib/avo/resources/base.rb:181` — `route_key`: `class_name.underscore.pluralize` — must return last-segment plural only (the helper identifier), e.g., `"invoices"` not `"accounts/invoices"`
- New method `route_path` needed for the URL slug, e.g., `"accounts/invoices"`

**All `route_key` call sites (must remain compatible after rename to helper identifier):**
- `app/helpers/avo/url_helpers.rb:15,19` — index path: `avo.send :"resources_#{route_key}_path"`
- `app/helpers/avo/url_helpers.rb:17` — uncountable guard: `if resource.route_key == resource.singular_route_key`
- `app/helpers/avo/url_helpers.rb:80,82` — association index: `resources_associations_index_path(route_key, ...)`
- `config/routes/dynamic_routes.rb:2` — route generation: `resources resource.route_key`
- `lib/avo/resources/array_resource.rb:61,63` — association field lookup (uses as method name, unaffected by routing change)

**All `singular_route_key` call sites:**
- `app/helpers/avo/url_helpers.rb:17,29,36,40,44` — show/preview/new/edit/association-new paths
- `app/components/avo/fields/tiptap_field/edit_component.rb:15`
- `app/components/avo/fields/trix_field/edit_component.rb:9`

**`class_name` derived usages that need splitting into display vs. convention:**
- `base.rb:165` — `class_name.safe_constantize` (model resolution) → wants full namespaced name → `class_name` change fixes this
- `base.rb:181` — `route_key` → needs last-segment only → new logic
- `base.rb:189` — `translation_key`: `"avo.resource_translations.#{class_name.underscore}"` → for namespaced: produces `"avo.resource_translations.accounts/invoice"`. Slash-separated keys are valid I18n and follow the Rails `model_name.i18n_key` convention; this is the desired behavior so namespaced resources get distinct translation keys.
- `base.rb:194` — `name` (display): `class_name.underscore.humanize` → should use last segment only for human name (display labels stay terse; namespacing belongs in the translation key, not the display string)

**`file_hash` and `file_name`:**
- `base.rb:583-595` — `file_hash` builds path: `Rails.root.join("app", "avo", "resources", "#{file_name}.rb")`
- `base.rb:598-600` — `file_name`: `self.class.underscore_name.tr(" ", "_")`
- `base.rb:221-223` — `underscore_name`: `name.demodulize.underscore` — uses display `name`, produces `"invoice"` not `"accounts/invoice"`
- Must produce subdirectory path: `"accounts/invoice"` for `Avo::Resources::Accounts::Invoice`

**`get_resource_by_controller_name`:**
- `lib/avo/resources/resource_manager.rb:142-147` — current: `resource.model_class.to_s.pluralize.underscore.tr("/", "_") == name`
- Called from `app/controllers/avo/base_application_controller.rb:83` with `@resource_name` (the controller name from the HTTP request)
- For namespaced resources, `@resource_name` comes from URL parsing; with per-resource routes, controller will receive the correct resource identity from route params

**`check_bad_resources`:**
- `lib/avo/resources/resource_manager.rb:76-77` — `possible_model = resource.to_s.gsub "Avo::Resources::", ""` — this already strips correctly and will work after our `class_name` change since we're not touching the error message derivation (it uses `resource.to_s` not `class_name`)

**Wildcard routes to migrate into dynamic_routes.rb** (inside `scope "resources"` in `config/routes.rb`):
- `line 25` — `delete "/:resource_name/:id/active_storage_attachments/:attachment_name/:attachment_id"`, `to: "attachments#destroy"`
- `lines 28-29` — actions: `get "/:resource_name(/:id)/actions/(:action_id)"`, `to: "actions#show"` and `#handle`
- `lines 36-40` — associations: 5 routes using `/:resource_name/:id/:related_name[/:related_id]`

**Routes to keep as wildcard** (outside `scope "resources"` or avo_api scope):
- `avo_api`: `get "/:resource_name/search"` and `post "/resources/:resource_name/:id/attachments/"`
- standalone: `get "/:resource_name/:field_id/distribution_chart"`

**Controller generator:**
- `lib/generators/avo/controller_generator.rb` — `controller_name`: `"#{plural_name}_controller"` — Rails `NamedBase` `plural_name` for `"Accounts::Invoice"` = `"accounts/invoices"`, so path is already correct (`app/controllers/avo/accounts/invoices_controller.rb`)
- `controller_class`: `"Avo::#{class_name.camelize.pluralize}Controller"` — for `"Accounts::Invoice"` produces `"Avo::AccountsInvoicesController"` ❌, needs `"Avo::Accounts::InvoicesController"` ✓

**Resource generator:**
- `lib/generators/avo/resource_generator.rb:33` — `template "resource/resource.tt", "app/avo/resources/#{resource_name}.rb"` — `resource_name` is raw input; for `"Accounts::Invoice"` produces wrong path; should use `file_path` (Rails `NamedBase` provides `file_path = "accounts/invoice"` for `"Accounts::Invoice"`)
- `lib/generators/avo/resource_generator.rb:101-108` — `model_class_from_args` currently injects `self.model_class` when `class_name.include?("::")` — must stop doing this for namespaced resources (the convention handles it); only inject when `--model-class` flag is explicit

**Routing — validated approach** (empirically verified against Rails 8.1 / ActionDispatch):
- `resources :accounts_invoices, path: "accounts/invoices", controller: "accounts/invoices"` produces correct named helpers and URLs inside `isolate_namespace Avo`
- Resources **must be sorted by path depth descending** before route generation to prevent shallow routes from claiming deep paths (e.g., `resources :accounts` must come after `resources :accounts_invoices` or `/avo/resources/accounts/invoices` matches `accounts#show` with `id: "invoices"`)
- `scope "accounts/invoices", as: "accounts_invoices"` alongside the `resources` block produces consistent helper names: `resources_accounts_invoices_associations_index_path(id, related_name)`

### Institutional Learnings

No directly applicable solutions found in `docs/solutions/`.

### External References

- Rails routing behavior with `path:` option and `isolate_namespace` validated against ActionDispatch 8.1 (behavior identical to 7.x for these features)

## Key Technical Decisions

- **`class_name` returns full relative name, not just last segment:** `to_s.delete_prefix("Avo::Resources::")` makes `class_name` return `"Accounts::Invoice"` for `Avo::Resources::Accounts::Invoice` and `"User"` for `Avo::Resources::User`. All model resolution, route path, and file path derivation flow from this. This is the single load-bearing change; all others are downstream corrections.

- **`route_key` stays as the Rails identifier (underscore-joined, last-segment plural):** `route_key` = `"accounts_invoices"` (used in `resources :accounts_invoices` and in dynamic helper names via `send :"resources_#{route_key}_path"`). This matches the existing call-site pattern and requires no change to how URL helpers construct method names — only the method itself changes to produce the right value.

- **New `route_path` for URL slug:** `route_path` = `"accounts/invoices"` (slash-separated path). Used in `path: resource.route_path` in the `resources` call. For non-namespaced resources, `route_path == route_key`, so non-namespaced routing is unchanged.

- **`controller_path` for controller routing:** `"accounts/invoices"` (slash-separated, used in `controller: resource.controller_path`). Inside `isolate_namespace Avo`, this resolves to `Avo::Accounts::InvoicesController`. For flat resources, `controller_path = "users"` resolves to `Avo::UsersController` — identical to the current behavior where no `controller:` is specified.

- **Display methods use last segment only; translation key includes the full namespace:** `name` and `initials` default to `demodulized_class_name` (the last segment: `"Invoice"` for `Accounts::Invoice`) — display labels stay terse and avoid awkward forms like "Accounts Invoice". `translation_key` defaults to `"avo.resource_translations.#{class_name.underscore}"` (slash-separated, mirroring Rails' `model_name.i18n_key`), so `Accounts::Invoice` and `Billing::Invoice` get distinct keys (`accounts/invoice` and `billing/invoice`) without requiring `custom_translation_key`. Existing flat resources keep their unchanged keys (`User` → `user`); apps that previously relied on the demodulized form for namespaced resources need to either move their YAML keys under the namespaced path or set `self.translation_key` explicitly.

- **All routes inside `scope "resources"` move to per-resource generation:** The shared wildcard routes for attachments, actions, and associations are removed from `config/routes.rb` and generated per-resource in `dynamic_routes.rb`. Resources are sorted by `route_path.count("/")` descending to prevent shallow routes from ambiguously matching deep paths. This satisfies R9 (all resource URLs use consistent nested paths).

- **`avo_api` and distribution chart routes keep single-segment wildcard:** These internal routes use `route_key` (underscore form) as the `/:resource_name` value. They are not visible in the browser URL bar during normal navigation and are exempt from R9.

- **`file_hash` uses `class_name.underscore` for path construction:** `"Accounts::Invoice".underscore = "accounts/invoice"`, which maps to `app/avo/resources/accounts/invoice.rb`. Non-namespaced resources: `"User".underscore = "user"` → same as before.

## Open Questions

### Resolved During Planning

- **Routing strategy for multi-segment resource names**: Per-resource route generation (Option A from brainstorm) is the correct choice. Glob params and custom constraints don't work cleanly when followed by dynamic `:id` and `:related_name` segments. This was empirically validated.
- **Route ordering**: Resources must be sorted by path depth (deepest first) to prevent ambiguous matching. Implemented in `dynamic_routes.rb` with `sort_by { [-resource.route_path.count("/"), resource.route_path] }`.
- **Named route helper scheme**: `resources :accounts_invoices, path: "accounts/invoices"` produces `resources_accounts_invoices_path` etc. — confirmed consistent with existing URL helper send-pattern.
- **`get_resource_by_controller_name` update**: The method's current implementation matches by `resource.model_class.to_s.pluralize.underscore.tr("/", "_")`. For `Accounts::Invoice`, this produces `"accounts_invoices"`. The controller name sent from `base_application_controller.rb` also becomes `"accounts_invoices"` (since the named route's controller is `Avo::Accounts::InvoicesController` whose `controller_name` = `"invoices"` but the `@resource_name` is extracted differently). This needs careful validation — see Deferred section.

### Deferred to Implementation

- **`@resource_name` extraction in `base_application_controller.rb`**: Currently set from `controller_name` (the Rails controller class's `controller_name`). For `Avo::Accounts::InvoicesController`, `controller_name = "invoices"`. The lookup `get_resource(@resource_name.to_s.camelize.singularize)` would try `get_resource("Invoice")` → `Avo::Resources::Invoice` (wrong namespace). Need to verify how `@resource_name` is actually set and whether it needs to include namespace segments. Investigate `base_application_controller.rb` lines 56–99 during implementation.
- **Translation key collision for same-last-segment across namespaces**: Resolved during implementation. `translation_key` now uses the full underscored class name (`avo.resource_translations.accounts/invoice` vs `avo.resource_translations.billing/invoice`), so two resources with the same leaf segment get distinct keys without configuration. See "Key Technical Decisions" for the trade-off and migration note for apps that already had locale entries under the demodulized form.
- **Policy file path in `file_hash`**: The policy path uses `file_name.gsub("_resource", "")`. For namespaced resources, `file_name = "accounts/invoice"` → policy path = `app/policies/accounts/invoice_policy.rb`. Verify this is the correct Pundit convention for namespaced models.
- **`uncountable_models` compatibility with `route_path`**: The `model_key` method exists to handle uncountable models (see `base.rb:169-173`). Verify `route_path` derivation works correctly for uncountable namespaced models.

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce.*

**Method derivation chain for `Avo::Resources::Accounts::Invoice`:**

```
to_s  →  "Avo::Resources::Accounts::Invoice"
  │
  ├─ class_name         →  "Accounts::Invoice"      (delete_prefix "Avo::Resources::")
  │    │
  │    ├─ model resolution  →  Accounts::Invoice.safe_constantize
  │    ├─ route_path         →  "accounts/invoices"  (underscore segments, pluralize last)
  │    ├─ route_key          →  "accounts_invoices"  (route_path.tr("/","_"))
  │    ├─ controller_path    →  "accounts/invoices"  (same as route_path)
  │    ├─ translation_key    →  "avo.resource_translations.accounts/invoice"  (class_name.underscore)
  │    └─ file path          →  "accounts/invoice"   (underscore, no pluralize)
  │
  └─ demodulized_class_name  →  "Invoice"           (last segment only, for display)
       │
       ├─ name               →  "Invoice"  (humanized)
       └─ initials           →  "In"
```

**Route generation in `dynamic_routes.rb`** (conceptual, within `scope "resources", as: "resources"`):

```
sorted resources (deepest route_path first):
  ├─ Avo::Resources::Accounts::Invoice  (route_path: "accounts/invoices", depth: 1)
  │    resources :accounts_invoices, path: "accounts/invoices", controller: "accounts/invoices"
  │    scope "accounts/invoices", as: "accounts_invoices" do
  │      ← actions, associations, attachment routes ─┐
  │    end                                            │
  └─ Avo::Resources::User  (route_path: "users", depth: 0)  │
       resources :users, path: "users", controller: "users"  │
       scope "users", as: "users" do                          │
         ← same route pattern ──────────────────────────────┘
       end
```

**Route pattern per resource** (inside each resource's `scope` block):
```
GET  /:id/actions/:action_id         → actions#show
POST /:id/actions/:action_id         → actions#handle
GET  /:id/:related_name/new          → associations#new
GET  /:id/:related_name/             → associations#index
GET  /:id/:related_name/:related_id  → associations#show
POST /:id/:related_name              → associations#create
DEL  /:id/:related_name/:related_id  → associations#destroy
DEL  /:id/active_storage_attachments/:name/:attachment_id → attachments#destroy
```

**Named helper change for associations in `url_helpers.rb`:**
```
# Before (positional arg):
resources_associations_index_path(route_key, id, related_name)

# After (helper name includes resource key):
send(:"resources_#{route_key}_associations_index_path", id, related_name)
```

## Implementation Units

```mermaid
TB
  A["Unit 1: base.rb — class_name & derived methods"]
  B["Unit 2: resource_manager.rb — lookups"]
  C["Unit 3: dynamic_routes.rb + routes.rb — per-resource routes"]
  D["Unit 4: url_helpers.rb — helper name construction"]
  E["Unit 5: controller_generator.rb — namespaced controller"]
  F["Unit 6: resource_generator.rb — nested file structure"]
  G["Unit 7: Tests"]

  A --> B
  A --> C
  A --> E
  A --> F
  C --> D
  B --> G
  C --> G
  D --> G
  E --> G
  F --> G
```

---

- [x] **Unit 1: Extend `Avo::Resources::Base` with namespaced conventions**

**Goal:** Change `class_name` to return the full relative class name, add display-only `demodulized_class_name`, derive `route_path` / `route_key` / `controller_path` / `file_hash` path from the new convention. All non-namespaced resources remain identical.

**Requirements:** R1, R2, R3, R7, R8, R10

**Dependencies:** None

**Files:**
- Modify: `lib/avo/resources/base.rb`
- Test: `spec/avo/resources/base_spec.rb` (or nearest equivalent resource unit test)

**Approach:**
- `class_name`: change `to_s.demodulize` → `to_s.delete_prefix("Avo::Resources::")`. For `Avo::Resources::User` this returns `"User"` (unchanged). For `Avo::Resources::Accounts::Invoice` returns `"Accounts::Invoice"`.
- Add `demodulized_class_name`: `class_name.demodulize` — returns last segment for display use.
- `name` method (display, `base.rb:194`): change `class_name.underscore.humanize` → `demodulized_class_name.underscore.humanize`. Preserves existing display names.
- `initials` (`base.rb:199`): change to use `demodulized_class_name`.
- `translation_key` (`base.rb:189`): use `class_name.underscore` so namespaced resources get distinct keys (`avo.resource_translations.accounts/invoice`). Flat resources are unchanged (`avo.resource_translations.user`). Slash-separated keys mirror Rails' `model_name.i18n_key` and are valid I18n keys. Apps with existing locale entries under the old demodulized form need to update YAML or set `self.translation_key` explicitly.
- `route_path` (new method): derives `"accounts/invoices"` from `class_name`. Split `class_name` on `::`, underscore all segments, pluralize the last one, join with `/`. For `"User"` returns `"users"` (single segment, same as current `route_key`).
- `route_key` (existing, `base.rb:180`): change to `route_path.tr("/", "_")`. For `"User"` returns `"users"` (unchanged). For `"Accounts::Invoice"` returns `"accounts_invoices"`.
- `singular_route_key` (existing, `base.rb:184`): remains `route_key.singularize`. Returns `"accounts_invoice"` for namespaced resource.
- `controller_path` (new method): same derivation as `route_path` but without pluralizing — `"accounts/invoices"`. Inside `isolate_namespace Avo`, `controller: "accounts/invoices"` resolves to `Avo::Accounts::InvoicesController`.
- `file_hash` (`base.rb:583-595`): the resource file path is `Rails.root.join("app", "avo", "resources", *class_name.underscore.split("/")).then { _1.sub_ext(".rb") }` — use `class_name.underscore` split on `/` to build the path segments. For `"User"` this is `app/avo/resources/user.rb` (unchanged). For `"Accounts::Invoice"` this is `app/avo/resources/accounts/invoice.rb`.
- The `underscore_name` / `file_name` methods are used by `file_hash` — verify whether they also need updating or if `file_hash` can be changed to bypass them.

**Patterns to follow:**
- `lib/avo/resources/base.rb:176-186` for how `class_name`, `route_key`, and `singular_route_key` are currently defined

**Test scenarios:**
- Happy path: `Avo::Resources::User.class_name` returns `"User"` (backward-compatible, unchanged)
- Happy path: `Avo::Resources::Accounts::Invoice.class_name` returns `"Accounts::Invoice"`
- Happy path: `Avo::Resources::Accounts::Invoice.demodulized_class_name` returns `"Invoice"`
- Happy path: `Avo::Resources::Accounts::Invoice.name` returns `"Invoice"` (display, humanized)
- Happy path: `Avo::Resources::Accounts::Invoice.route_path` returns `"accounts/invoices"`
- Happy path: `Avo::Resources::Accounts::Invoice.route_key` returns `"accounts_invoices"`
- Happy path: `Avo::Resources::Accounts::Invoice.singular_route_key` returns `"accounts_invoice"`
- Happy path: `Avo::Resources::Accounts::Invoice.controller_path` returns `"accounts/invoices"`
- Happy path: `Avo::Resources::Accounts::Invoice.translation_key` returns `"avo.resource_translations.accounts/invoice"`
- Happy path: `Avo::Resources::User.translation_key` returns `"avo.resource_translations.user"` (unchanged)
- Happy path: `Avo::Resources::User.route_path` returns `"users"` (same as current `route_key`, unchanged)
- Happy path: model auto-resolution — resource with no `self.model_class` resolves `Accounts::Invoice` model
- Edge case: deeply nested `Avo::Resources::A::B::C` — `route_path` = `"a/b/cs"`, `route_key` = `"a_b_cs"`
- Backward compatibility: existing resource with `self.model_class = "Accounts::Invoice"` on a flat class — override still takes priority

**Verification:**
- All existing resource tests pass without modification
- A resource class `Avo::Resources::Accounts::Invoice` with no `self.model_class` resolves to `Accounts::Invoice` model

---

- [x] **Unit 2: Update `ResourceManager` controller name lookup and error messages**

**Goal:** Update `get_resource_by_controller_name` to correctly match namespaced resources, and verify `check_bad_resources` error messages remain meaningful.

**Requirements:** R14

**Dependencies:** Unit 1 (needs `route_key` to return underscore-joined form)

**Files:**
- Modify: `lib/avo/resources/resource_manager.rb`
- Test: `spec/avo/resources/resource_manager_spec.rb` (or equivalent)

**Approach:**
- `get_resource_by_controller_name` currently: `resource.model_class.to_s.pluralize.underscore.tr("/", "_") == name`
- For `Accounts::Invoice`: `"Accounts::Invoice".pluralize.underscore.tr("/", "_")` = `"accounts_invoices"`. The `name` parameter from `base_application_controller.rb` needs to match this. With per-resource routes (Unit 3), the controller for the namespaced resource is `Avo::Accounts::InvoicesController` whose Rails `controller_name` = `"invoices"` (not `"accounts_invoices"`). Investigate how `@resource_name` is set in `base_application_controller.rb:56-99` and determine whether the match logic needs updating or whether a new method `resource.route_key` should be compared. The current implementation may already work if `@resource_name` is set from the route's `as:` name rather than the controller class name.
- `check_bad_resources` at `resource_manager.rb:76-77`: `resource.to_s.gsub "Avo::Resources::", ""` already produces `"Accounts::Invoice"` — no change needed there.
- `get_resource` at `resource_manager.rb:96-100`: prepends `"Avo::Resources::"` when not already present — verify this still works for namespaced resource lookups like `get_resource("Accounts::Invoice")`.

**Patterns to follow:**
- `lib/avo/resources/resource_manager.rb:126-136` for `get_resource_by_model_class` as reference

**Test scenarios:**
- Happy path: `get_resource_by_controller_name("users")` returns `Avo::Resources::User` class
- Happy path: `get_resource_by_controller_name("accounts_invoices")` returns `Avo::Resources::Accounts::Invoice` class (or whatever the correct identifier turns out to be after investigating `@resource_name` extraction)
- Happy path: `get_resource("Accounts::Invoice")` resolves `Avo::Resources::Accounts::Invoice`
- Backward compatibility: existing flat resources still found by their controller names

**Verification:**
- Navigating to `/avo/resources/accounts/invoices` in a test app routes to the correct resource

---

- [x] **Unit 3: Migrate wildcard routes to per-resource generation in `dynamic_routes.rb`**

**Goal:** Generate all `scope "resources"` routes (CRUD, actions, associations, attachment-destroy) per resource. Remove the shared wildcard routes from `config/routes.rb`. Sort resources by path depth to prevent ambiguous matching.

**Requirements:** R8, R9, R10, R11, R12, R17

**Dependencies:** Unit 1 (needs `route_path`, `route_key`, `controller_path`)

**Files:**
- Modify: `config/routes/dynamic_routes.rb`
- Modify: `config/routes.rb` (remove wildcard routes inside `scope "resources"`)
- Test: `spec/routing/` or system/request specs that test URLs

**Approach:**
- Sort resources by `route_path.count("/")` descending before generating routes. Within the same depth, sort alphabetically by `route_path`. This ensures `/avo/resources/accounts/invoices` is declared before `/avo/resources/accounts` and cannot be ambiguously matched.
- For each resource, generate:
  1. `resources route_key, path: route_path, controller: controller_path` with `search` collection and `preview/new/edit` member routes (same as current)
  2. `scope route_path, as: route_key` block with:
     - Actions: `GET /:id/actions/:action_id → actions#show`, `POST /:id/actions/:action_id → actions#handle`
     - Associations: 5 routes for new/index/show/create/destroy
     - Attachment destroy: `DELETE /:id/active_storage_attachments/:attachment_name/:attachment_id → attachments#destroy`
- Named route `as:` values inside each `scope` block must match the existing names (`associations_new`, `associations_index`, `associations_show`, `associations_create`, `associations_destroy`, `actions_show`, `actions_handle`) so that url_helpers.rb send-pattern constructs the right helper name.
- Remove from `config/routes.rb` inside `scope "resources"`: the attachment destroy, actions, and associations wildcard routes (lines 25, 28–29, 36–40). Keep: the `draw(:dynamic_routes)` call.
- Routes outside `scope "resources"` (avo_api, distribution_chart) are untouched.
- Non-namespaced resources: `route_path = route_key = "users"`, `controller_path = "users"`. Their generated routes are identical to current behavior (`resources :users, path: "users", controller: "users"` with `scope "users", as: "users"` for sub-routes).

**Patterns to follow:**
- `config/routes/dynamic_routes.rb:1-11` (current implementation to expand)
- `config/routes.rb:23-42` (current routes block to partially delete)

**Test scenarios:**
- Happy path: `GET /avo/resources/users` routes to `Avo::UsersController#index` (no regression for flat)
- Happy path: `GET /avo/resources/accounts/invoices` routes to `Avo::Accounts::InvoicesController#index`
- Happy path: `GET /avo/resources/accounts/invoices/123` routes to `#show`
- Happy path: `GET /avo/resources/accounts/invoices/123/comments/` routes to `associations#index` with `related_name: "comments"`
- Happy path: `GET /avo/resources/accounts/invoices/123/actions/my_action` routes to `actions#show`
- Happy path: `DELETE /avo/resources/accounts/invoices/123/active_storage_attachments/avatar/456` routes to `attachments#destroy`
- Edge case: two resources `Avo::Resources::Accounts` and `Avo::Resources::Accounts::Invoice` — verify `/avo/resources/accounts/invoices` routes to `Accounts::Invoice` not `Accounts#show(id: "invoices")`
- Backward compatibility: all existing route specs pass unchanged for non-namespaced resources

**Verification:**
- `rails routes` output shows per-resource routes for both flat and namespaced resources with correct paths and named helpers

---

- [x] **Unit 4: Update URL helpers to use per-resource named helpers for associations and actions**

**Goal:** Change association and action path helper calls in `url_helpers.rb` from positional-arg shared helpers (`resources_associations_index_path(route_key, id, related_name)`) to per-resource send-pattern helpers (`send(:"resources_#{route_key}_associations_index_path", id, related_name)`).

**Requirements:** R13

**Dependencies:** Unit 3 (per-resource named helpers must exist before url_helpers can call them)

**Files:**
- Modify: `app/helpers/avo/url_helpers.rb`
- Test: `spec/helpers/avo/url_helpers_spec.rb` or system tests covering association/action links

**Approach:**
- Line 48 (association new): `resources_associations_new_path(resource.singular_route_key, record_id, related_name)` → `send(:"resources_#{resource.singular_route_key}_associations_new_path", record_id, related_name)`. Note: `singular_route_key` is used here (matching the `as:` convention for the member-style route name).
- Line 82 (association index): `resources_associations_index_path(route_key, record.to_param, **args)` → `send(:"resources_#{route_key}_associations_index_path", record.to_param, **args)`
- Check all other association/action URL construction in the file (lines 48, 80-82 confirmed; verify full file for any missed `resources_associations_*` or `resources_actions_*` calls)
- CRUD helpers (lines 19, 29, 36, 40, 44) already use `send(:"resources_#{route_key}_path")` pattern — no change needed since `route_key` now returns the underscore-joined form which matches the helper name
- Verify action URL construction — find where `resources_actions_show_path` / `resources_actions_handle_path` are called and update to `resources_#{route_key}_actions_show_path`

**Patterns to follow:**
- `app/helpers/avo/url_helpers.rb:15-19` (existing send-pattern for CRUD, mirror it for associations/actions)

**Test scenarios:**
- Happy path: association index URL for `Accounts::Invoice` with `comments` → `/avo/resources/accounts/invoices/123/comments/`
- Happy path: association new URL for `Accounts::Invoice` → `/avo/resources/accounts/invoices/123/comments/new`
- Happy path: action URL for `Accounts::Invoice` → `/avo/resources/accounts/invoices/123/actions/export`
- Happy path: CRUD URLs for `User` unchanged: `resource_path`, `resources_path`, `new_resource_path`, `edit_resource_path`
- Backward compatibility: association URLs for existing flat resources (`User`) remain unchanged

**Verification:**
- In a test app, navigating an `Accounts::Invoice` resource shows correct URLs in association tabs and action buttons

---

- [x] **Unit 5: Update controller generator for namespaced controller output**

**Goal:** `rails generate avo:resource Accounts::Invoice` produces `Avo::Accounts::InvoicesController` at `app/controllers/avo/accounts/invoices_controller.rb`.

**Requirements:** R16

**Dependencies:** None (generator is standalone; does not depend on runtime resource changes)

**Files:**
- Modify: `lib/generators/avo/controller_generator.rb`
- Test: `spec/generators/avo/controller_generator_spec.rb` or generator integration test

**Approach:**
- `controller_name` (returns file path): `"#{plural_name}_controller"` — Rails `NamedBase.plural_name` for `"Accounts::Invoice"` = `"accounts/invoices"`, so `controller_name = "accounts/invoices_controller"`. This maps to `app/controllers/avo/accounts/invoices_controller.rb`. No change needed to `controller_name`.
- `controller_class` (returns class name): currently `"Avo::#{class_name.camelize.pluralize}Controller"`. For `"Accounts::Invoice"`, this produces `"Avo::AccountsInvoicesController"` (wrong). Change to handle `::` in class_name: split on `::`, camelize all parts, pluralize the last part, join with `::`, wrap with `Avo::..Controller`:
  - `"Accounts::Invoice"` → `["Accounts", "Invoice"]` → pluralize last → `["Accounts", "Invoices"]` → `"Avo::Accounts::InvoicesController"`
  - `"User"` → `["User"]` → `["Users"]` → `"Avo::UsersController"` (unchanged)
- The controller template (`lib/generators/avo/templates/resource/controller.tt`) uses `<%= controller_class %>` — no template change needed.

**Patterns to follow:**
- `lib/generators/avo/controller_generator.rb` (existing implementation)
- `lib/generators/avo/resource_generator.rb` for how the generator invokes the controller generator

**Test scenarios:**
- Happy path: generate `Accounts::Invoice` → file `app/controllers/avo/accounts/invoices_controller.rb`, class `Avo::Accounts::InvoicesController < [parent_controller]`
- Happy path: generate `User` → file `app/controllers/avo/users_controller.rb`, class `Avo::UsersController < [parent_controller]` (unchanged behavior)
- Edge case: generate `A::B::C` → file `app/controllers/avo/a/b/cs_controller.rb`, class `Avo::A::B::CsController`

**Verification:**
- Running the generator produces the correct file with the correct class declaration

---

- [x] **Unit 6: Update resource generator for nested file structure**

**Goal:** `rails generate avo:resource Accounts::Invoice` produces the resource file at `app/avo/resources/accounts/invoice.rb` and does not inject `self.model_class` (since convention handles it).

**Requirements:** R4, R5, R6

**Dependencies:** None (generator standalone)

**Files:**
- Modify: `lib/generators/avo/resource_generator.rb`
- Test: `spec/generators/avo/resource_generator_spec.rb`

**Approach:**
- File path: change `"app/avo/resources/#{resource_name}.rb"` → `"app/avo/resources/#{file_path}.rb"`. Rails `NamedBase.file_path` for `"Accounts::Invoice"` = `"accounts/invoice"`. For `"User"` = `"user"` (unchanged).
- `model_class_from_args`: currently injects `self.model_class` when `class_name.include?("::")`. Remove that condition; only inject when `--model-class` flag (`class_from_args`) is explicitly provided:
  - Before: `if class_from_args.present? || class_name.include?("::")`
  - After: `if class_from_args.present?`
- The resource template already uses `<%= resource_class %>` which is derived from `class_name`. For `"Accounts::Invoice"`, `class_name = "Accounts::Invoice"`, so the generated class declaration is `class Avo::Resources::Accounts::Invoice < Avo::BaseResource` — correct, no template change needed.
- Verify the `create` method's `template` call correctly creates subdirectories (Rails generators handle this automatically when the file path contains `/`).

**Patterns to follow:**
- `lib/generators/avo/resource_generator.rb:33` and `101-108`
- `lib/generators/avo/named_base_generator.rb` for `file_path` availability

**Test scenarios:**
- Happy path: generate `Accounts::Invoice` → file at `app/avo/resources/accounts/invoice.rb`, class `Avo::Resources::Accounts::Invoice`, no `self.model_class` line
- Happy path: generate `Accounts::Invoice --model-class Billing::Invoice` → file at correct path, `self.model_class = ::Billing::Invoice` injected
- Happy path: generate `User` → file at `app/avo/resources/user.rb` (unchanged behavior)
- Happy path: generate `SuperDooperTrooperModel` (flat) → `app/avo/resources/super_dooper_trooper_model.rb`, no `self.model_class` (no `::` in name)
- Edge case: running the generator twice — no overwrite prompt regression

**Verification:**
- `rails generate avo:resource Accounts::Invoice` in a test app produces both the resource file and controller file at correct paths with correct class declarations and no `self.model_class` injection

---

- [x] **Unit 7: Integration and regression tests**

**Goal:** Validate end-to-end: a namespaced resource discovers, routes, renders, and generates correctly. Confirm no regression for flat resources.

**Requirements:** All R1–R17, Success Criteria

**Dependencies:** Units 1–6 complete

**Files:**
- Create or expand: `spec/system/avo/namespaced_resources_spec.rb` (system tests) or `spec/requests/avo/namespaced_resources_spec.rb`
- Check: `spec/generators/avo/resource_generator_spec.rb`

**Approach:**
- Set up a dummy namespaced model (`Accounts::Invoice`) and resource (`Avo::Resources::Accounts::Invoice`) in the spec support files
- Test resource discovery, URL generation, CRUD routing, action routing, and association routing
- Confirm existing resource system tests pass without modification (regression guard)

**Test scenarios:**
- Integration: `Avo::Resources::Accounts::Invoice` is present in `Avo.resource_manager.resources` list at boot
- Integration: `Avo.resource_manager.get_resource_by_model_class(Accounts::Invoice)` returns the resource
- Integration: `GET /avo/resources/accounts/invoices` returns 200 and renders the index
- Integration: `GET /avo/resources/accounts/invoices/1` returns 200 and renders show
- Integration: action route `GET /avo/resources/accounts/invoices/1/actions/my_action` returns expected response
- Integration: association URL helper for `Accounts::Invoice` produces `/avo/resources/accounts/invoices/1/comments/`
- Integration: resource with explicit `self.model_class = "Accounts::Invoice"` on `Avo::Resources::AccountsInvoice` still works (R15)
- Regression: `GET /avo/resources/users` still works correctly
- Generator: `rails generate avo:resource Accounts::Invoice` produces correct files (both resource and controller)

**Verification:**
- CI passes with all existing tests green
- New test suite passes for namespaced resource scenarios

---

## System-Wide Impact

- **Interaction graph:** `Avo::Current.resource_manager` is rebuilt on every request. All resource lookups flow through `ResourceManager`. The `base_application_controller.rb` `set_resource` callback chain uses `@resource_name` from the controller context — this is the most sensitive integration point and is explicitly flagged as a deferred implementation question.
- **Error propagation:** A misconfigured namespaced resource (file exists, class defined, model doesn't exist) goes through `check_bad_resources` which will produce the error message using `resource.to_s.gsub "Avo::Resources::", ""` — already works correctly.
- **State lifecycle risks:** `class_name` is memoized (`@class_name ||=`). Any test that mutates or redefines a resource class must clear this. No production risk since resource classes are loaded once.
- **API surface parity:** `route_key` is used in `Avo::Resources::ArrayResource` (`array_resource.rb:61,63`) as a method name on the record (e.g., `via_record.try(route_key)`). For namespaced resources, `route_key = "accounts_invoices"` — confirm this association field lookup still resolves correctly (the method name on the model should be the pluralized association name, not the namespaced identifier).
- **Integration coverage:** The `url_helpers.rb` change from positional-arg to send-pattern for associations is the riskiest URL helper change. It must be covered by system tests that render actual association links for a namespaced resource.
- **Unchanged invariants:** Non-namespaced resources (`Avo::Resources::User` etc.) must produce identical URLs, named helpers, and file paths as today. The plan explicitly uses `route_path = route_key` for non-namespaced resources to ensure no behavioral change.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| `@resource_name` extraction in `base_application_controller.rb` may not match `route_key` for namespaced resources, causing resource lookup failures | Investigate `base_application_controller.rb:56-99` during Unit 2. If `@resource_name` is set from `controller_name` (which is just `"invoices"` for `Avo::Accounts::InvoicesController`), the lookup chain fails. May need to set `@resource_name` from a route param or use a different lookup strategy. |
| Route ordering — a flat resource `Avo::Resources::Accounts` and namespaced `Avo::Resources::Accounts::Invoice` clash if Accounts is declared first | Depth-descending sort in `dynamic_routes.rb` prevents this. Covered by Unit 3 test scenario. |
| `singular_route_key` used in `send(:"resources_#{singular_route_key}_associations_new_path")` — ensure `singular_route_key.singularize` of `"accounts_invoices"` = `"accounts_invoice"` and the named route uses the same form | Verify the `scope as:` name in per-resource routes uses `singular_route_key` convention for the singular-form helpers. Rails `resources` names member routes using the singular form by default. |
| Translation key collision between `Accounts::Invoice` and `Billing::Invoice` | Resolved: `translation_key` uses `class_name.underscore` (`accounts/invoice` vs `billing/invoice`), so they no longer collide. Flag the change in CHANGELOG for apps with existing locale YAML keyed on the demodulized form. |
| `array_resource.rb` uses `route_key` as an association method name on records — namespaced `route_key = "accounts_invoices"` may not match the actual association method | Investigate during Unit 1. If this is a problem, `route_key` for array-resource association lookup may need to remain the demodulized form. Alternatively, an `association_key` method separate from `route_key` may be needed. |

## Documentation / Operational Notes

- CHANGELOG entry needed: new convention for namespaced resources, migration path for existing flat-name workarounds
- CHANGELOG must call out the `translation_key` change: namespaced resources now produce slash-separated keys (`avo.resource_translations.accounts/invoice` instead of `avo.resource_translations.invoice`). Apps with existing locale entries keyed on the demodulized form need to either move them under the namespaced path or set `self.translation_key` explicitly. Flat resources are unaffected.
- Docs update: `https://docs.avohq.io` resource documentation to show namespaced example and note the `self.model_class` workaround remains supported

## Sources & References

- **Origin document:** [docs/brainstorms/2026-05-04-namespaced-resources-requirements.md](docs/brainstorms/2026-05-04-namespaced-resources-requirements.md)
- Related code: `lib/avo/resources/base.rb:176-186` (class_name, route_key)
- Related code: `app/helpers/avo/url_helpers.rb` (URL helper construction)
- Related code: `config/routes/dynamic_routes.rb` (per-resource route generation)
- Related code: `lib/generators/avo/resource_generator.rb`, `lib/generators/avo/controller_generator.rb`
- Related code: `lib/avo/resources/resource_manager.rb:142-147` (controller name lookup)
- Rails routing: `resources :name, path: "other/path"` + `isolate_namespace` behavior validated on ActionDispatch 8.1
