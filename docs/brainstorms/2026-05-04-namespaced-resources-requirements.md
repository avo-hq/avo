---
date: 2026-05-04
topic: namespaced-resources
---

# Namespaced Resources

## Problem Frame

Resources must currently live at a single flat level under `Avo::Resources::`. When a Rails app has namespaced models (e.g., `Accounts::Invoice`, `Super::Dooper::Trooper::Model`), the resource class must use a flattened name and override `self.model_class` explicitly:

```ruby
class Avo::Resources::AccountsInvoice < Avo::BaseResource
  self.model_class = "Accounts::Invoice"
end
```

This is verbose, forces an artificial naming mismatch, and prevents using a natural file structure. The fix should be transparent: a namespaced resource class auto-resolves to its namespaced model, lives in a subdirectory, and gets a URL that mirrors its namespace.

## Requirements

**Model Resolution**
- R1. A resource class whose Ruby namespace extends beyond `Avo::Resources::` — e.g., `Avo::Resources::Accounts::Invoice` — must automatically resolve to the matching model class `Accounts::Invoice` without requiring `self.model_class`.
- R2. Explicit `self.model_class` overrides must continue to work exactly as before, taking priority over the convention in all cases.
- R3. Existing flat resource classes (e.g., `Avo::Resources::User`) must behave identically to today — no change in model resolution, URL, or file location.

**File Structure**
- R4. A namespaced resource class must live in a subdirectory that mirrors its namespace: `Avo::Resources::Accounts::Invoice` lives at `app/avo/resources/accounts/invoice.rb`.
- R5. The generator must create the subdirectory and file in the correct location when invoked with a namespaced name (e.g., `rails generate avo:resource Accounts::Invoice`).
- R6. The generator must not inject `self.model_class` for a namespaced resource when the conventional path resolves correctly (it should only inject it when an explicit `--model-class` flag is given).
- R7. `file_hash` cache invalidation must work for files in subdirectories, not just flat `app/avo/resources/<name>.rb` paths.

**URL Structure**
- R8. The URL for a namespaced resource must mirror its namespace as nested path segments: `Avo::Resources::Accounts::Invoice` is served at `/avo/resources/accounts/invoices/`.
- R9. All resource-related URLs must use the same nested path consistently: CRUD routes, action routes, association routes, and search routes must all use `/avo/resources/accounts/invoices/...`.
- R10. Flat resources retain their current flat URLs (e.g., `/avo/resources/users/`). No URL changes for existing resources.

**Routing**
- R11. The dynamic route generator must produce correct named routes and URL path for namespaced resources (e.g., `resources :invoices` with `path: "accounts/invoices"` or equivalent nested scope), such that Rails generates helpers like `resources_accounts_invoices_path`.
- R12. Routes that currently use `/:resource_name` as a single-segment wildcard must be updated or replaced to correctly route requests where the resource name spans multiple path segments (e.g., `accounts/invoices`).
- R13. URL helper methods (`resources_path`, `resource_path`, `new_resource_path`, `edit_resource_path`) must construct correct URLs for namespaced resources.

**Runtime Lookup**
- R14. `get_resource_by_controller_name` must resolve the correct resource class when the request path contains a multi-segment resource identifier (e.g., `"accounts/invoices"` → `Avo::Resources::Accounts::Invoice`).

**Controller**
- R16. The controller generated for a namespaced resource must mirror the namespace: `Avo::Resources::Accounts::Invoice` generates `Avo::Accounts::InvoicesController` at `app/controllers/avo/accounts/invoices_controller.rb`.
- R17. The dynamic routes must specify the correct namespaced controller for namespaced resources (e.g., `controller: "avo/accounts/invoices"` in the `resources` call for `Avo::Resources::Accounts::Invoice`), so Rails routes requests to `Avo::Accounts::InvoicesController` rather than inferring a flat controller name.

**Backwards Compatibility**
- R15. Existing resources using `self.model_class` as a workaround (e.g., `Avo::Resources::AccountsInvoice` with `self.model_class = "Accounts::Invoice"`) continue to work. No breaking change is introduced for them; migration to the new convention is optional.

## Success Criteria

- A developer with `Accounts::Invoice` model can create `app/avo/resources/accounts/invoice.rb` defining `class Avo::Resources::Accounts::Invoice < Avo::BaseResource` with no other configuration, and the resource loads, resolves, and routes correctly.
- All existing resources (flat classes) require no changes and behave identically to today.
- The generator handles `rails generate avo:resource Accounts::Invoice` end-to-end, producing both the resource file and a correctly namespaced controller.
- No regression in URL helpers or route lookups for any resource type.

## Scope Boundaries

- Sidebar navigation grouping or visual organisation of namespaced resources is out of scope (separate feature).
- STI (Single Table Inheritance) support is unchanged — this feature does not affect STI behaviour.
- No changes to the Avo configuration format (e.g., `Avo.configuration.resources`); manual registration continues to work by passing fully-qualified class name strings.
- Deeply nested namespaces beyond two levels (e.g., `Avo::Resources::A::B::C`) should work by the same convention, but the implementation only needs to handle the general case — no depth limit is prescribed.

## Key Decisions

- **Automatic, not opt-in**: Namespaced resource classes get nested URLs automatically. The class structure determines everything; no extra configuration is required.
- **Backward-compatible**: Flat resource classes are unaffected. The workaround pattern continues to work.
- **Convention root**: `class_name` is redefined as `to_s.delete_prefix("Avo::Resources::")` — the full nested name relative to the Avo::Resources namespace. All derived methods (model resolution, route key, file path) flow from this single change.

## Dependencies / Assumptions

- Zeitwerk already handles nested files correctly: `app/avo/resources/accounts/invoice.rb` autoloads as `Avo::Resources::Accounts::Invoice` because `app/avo/` is pushed into Zeitwerk under the `Avo` namespace. No Zeitwerk changes needed.
- The existing `model_resource_mapping` config option (`Avo.configuration.model_resource_mapping`) continues to act as a hard override before convention-based lookup.

## Outstanding Questions

### Deferred to Planning

- **[Affects R11, R12, R13][Technical]** What is the cleanest routing strategy to make all wildcard routes (`/:resource_name`) support multi-segment resource names without ambiguity? Options: (a) generate per-resource routes for actions/associations inside `dynamic_routes.rb`, removing the shared wildcards; (b) use a custom routing constraint that allows slashes in `resource_name`; (c) glob param `/*resource_name` with careful ordering. Route constraints appear most contained but need verification against Rails' routing behaviour with following dynamic segments.

- **[Affects R11, R13][Technical]** What naming scheme for the Rails `resources` call in `dynamic_routes.rb`? Option A: `resources :invoices, path: "accounts/invoices"` (keeps last-segment for the Rails name, uses path for the URL). Option B: `scope "accounts" { resources :invoices }`. Named route helpers differ between these — the planning phase should verify which produces helpers that match the existing URL helper call sites.

- **[Affects R14][Technical]** `get_resource_by_controller_name` currently matches on `resource.model_class.model_name.plural`. For namespaced resources, the controller path is a multi-segment string (e.g., `"accounts/invoices"`). A new `resource.route_path` method (derived from `class_name.underscore` with the last segment pluralized) should be the lookup key — validate during planning.

- **[Affects R7][Needs research]** `file_hash` currently builds the file path as `app/avo/resources/#{file_name}.rb`. The `file_name` method needs to produce a path-relative string for nested resources (e.g., `accounts/invoice`). Confirm no other path construction in `base.rb` or the concern files uses the same hardcoded pattern.

- **[Affects R5, R6, R16][Technical]** The generator uses `resource_name` to derive both the file path and the class name. For `Accounts::Invoice`, it must produce: resource file `accounts/invoice.rb` under `app/avo/resources/`, resource class `Avo::Resources::Accounts::Invoice`, controller file `accounts/invoices_controller.rb` under `app/controllers/avo/`, and controller class `Avo::Accounts::InvoicesController`. The `controller_class` method in `ControllerGenerator` currently uses `class_name.camelize.pluralize` (flat), which needs to produce the namespaced form. The `controller_name` method already derives `"accounts/invoices_controller"` from `plural_name` in Rails `NamedBase` conventions — verify this is correct end-to-end.

## Next Steps

→ `/ce:plan` for structured implementation planning
