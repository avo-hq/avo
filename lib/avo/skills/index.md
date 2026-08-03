# Avo skills index

These skills ship inside the installed `avo` gem, so they describe the Avo this app actually runs. Read the ones a task needs — usually one to three — and follow them over prior knowledge of Avo.

Each entry is a directory beside this file: `<skill>/SKILL.md`.

## Core

| Skill | Covers |
| --- | --- |
| `avo-resources` | Generate and configure resources — title, includes, sorting, pagination, cover/avatar, array (non-DB) resources |
| `avo-fields` | Add and configure fields in `def fields` — pick the `as:` type, options, formatting, layout |
| `avo-associations` | Wire `belongs_to` / `has_many` / `has_one` / HABTM fields, polymorphism, STI |
| `avo-actions` | Actions that run Ruby on selected, single, or no records — bulk ops, forms, modals, responses |
| `avo-filters` | Filter the index with basic filters. Dynamic filters and scopes are package-owned — see below |
| `avo-index-views` | How the index renders — table styling, grid cards, map markers, view types |
| `avo-custom-fields` | Build a brand-new field type — generator plus its Edit/Show/Index view components |

## Configuration and operations

| Skill | Covers |
| --- | --- |
| `avo-setup` | Install Avo, mount it, authenticate the private gem server, set the license key |
| `avo-update` | Bump the Avo gems and apply every upgrade-guide step for the versions crossed |
| `avo-authentication` | Tell Avo who the current user is, gate access, wire roles / profile / sign-out |
| `avo-admin-config` | Global initializer knobs — app name, per-page, container width, density, home path |
| `avo-performance` | Caching and stale-row fixes to make the admin fast |
| `avo-testing` | Unblock the license check in the test suite and use Avo's test helpers |
| `avo-multitenancy` | Scope the admin per tenant — route- or session-based, with an account switcher |

## Customization

| Skill | Covers |
| --- | --- |
| `avo-branding-appearance` | Logo, favicon, color scheme, palettes, CSS re-skin, icons |
| `avo-menu-icons` | Pick the right Tabler icon and apply it to resources. The menu DSL is `avo-menu`'s own skill |
| `avo-navigation-search` | Per-resource search, breadcrumbs, keyboard shortcuts, the auto-generated sidebar |
| `avo-custom-ui` | Custom pages, embedded panels, dynamic/nested forms, ejected views, Stimulus, Tailwind |
| `avo-i18n` | Translate and localize the admin — labels, locale switching, RTL |
| `avo-controllers` | Override per-resource CRUD controller hooks and safely extend Avo's ApplicationController |
| `avo-engine-internals` | `main_app`/`avo` helpers, `Avo::Current`, `ExecutionContext`, reserved names |
| `avo-media-library` | Central asset browser and a picker inside rich-text editors |

## Cross-cutting

| Skill | Covers |
| --- | --- |
| `avo-aware` | Keep the admin in sync when a Rails model changes, even when the request never mentions Avo |
| `avo-troubleshoot` | Diagnose a broken or misbehaving Avo app, organized by symptom |

## Package-owned skills

Features that live in their own gem ship their own skill. The loader lists the ones this app has installed and names the ones it does not, so nothing here points at a path that is absent. See `package-map.md` for the full map of gem to subject.
