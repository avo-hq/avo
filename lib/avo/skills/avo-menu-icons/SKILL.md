---
name: avo-menu-icons
description: Add icons to Avo menu items in config/initializers/avo.rb. Use when the user wants to populate icons for sidebar sections, groups, resources, links, and dashboards. Especially useful when migrating from Avo 3 to Avo 4.
allowed-tools: Read, Edit, Glob, Bash
metadata:
  avo-version: "4.0.24"
  requires-gem: avo-menu (https://avohq.io/addons/menu-editor) — only for the initializer menu DSL; resource icons are Community
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Add Icons to Avo Menu Items

> **The initializer menu DSL needs the `avo-menu` add-on.** Icons on resources, dashboards, and links are Community and work without it — Approach B below covers that path.
>
> Re-run the Avo skills loader to check whether `avo-menu` is in this app's `Gemfile.lock` before routing to Approach A.

Before doing anything, list the icon names available to this app. `<AVO_GEM_PATH>` is the path the Avo skills loader printed — this skill lives inside that gem, so build the path from it rather than from the app's working directory:

```bash
ruby <AVO_GEM_PATH>/lib/avo/skills/avo-menu-icons/scripts/list_icons.rb
```

That prints two lines, `outline: …` and `filled: …`, read straight from the installed `avo-icons` gem — no network call, so the names are exactly what this app can render. Pass `outline` or `filled` to get one style, or `--count` for just the totals.

To use an icon, prefix the name with `tabler/outline/` or `tabler/filled/` — e.g. `icon: "tabler/outline/users"`. Only use names the command printed.

---

## Determine the approach

There are two ways to add icons in Avo. Identify which one to use:

### Approach A — Initializer menu DSL

Use this when `config/initializers/avo.rb` contains a `config.main_menu` or `config.profile_menu` block. Icons are added inline to the DSL calls inside those blocks. The menu DSL requires the `avo-menu` paid add-on — if it's not installed, use Approach B instead.

### Approach B — Resource files

Use this when the initializer has **no** `config.main_menu` / `config.profile_menu` block, meaning Avo auto-generates the sidebar from the registered resources. Icons are added via `self.icon` inside each resource class.

**Decision rule:**

1. If the user explicitly says which approach they want, use that.
2. Otherwise, read `config/initializers/avo.rb`:
   - If it contains `config.main_menu` or `config.profile_menu` → use **Approach A**.
   - If neither block is present → use **Approach B**.

---

## Approach A — Add icons in the initializer

### Step 1: Read the Avo menu configuration

Find and read the Avo initializer — usually `config/initializers/avo.rb`. Locate the `config.main_menu` block and `config.profile_menu` if present.

### Step 2: Identify items without icons

For each DSL call inside the menu blocks, check whether it already has an `icon:` argument:

- `section "Name", ...`
- `group "Name", ...`
- `resource :name, ...`
- `link "Name", path: ..., ...`
- `dashboard :name, ...`

Collect every call that is missing `icon:`.

### Step 3: Choose icons

For each item without an icon, find the best-matching name from the outline list. Prefer outline icons; only use filled when it clearly fits better.

**Matching strategy — try in order:**

1. **Exact match** — the item name or a keyword from it appears verbatim in the list (e.g. `users` section → find `users`).
2. **Semantic match** — the concept maps to a well-known icon. Common hints:

   | Concept                    | Try these names                               |
   | -------------------------- | --------------------------------------------- |
   | Users / People / Members   | `users`, `user`, `user-circle`                |
   | Posts / Articles / Blog    | `article`, `news`, `writing`                  |
   | Orders / Purchases         | `shopping-cart`, `receipt`, `cash-register`   |
   | Products / Items / Catalog | `package`, `box`, `tag`                       |
   | Settings / Config          | `settings`, `adjustments`, `sliders`          |
   | Reports / Analytics        | `chart-bar`, `chart-line`, `report-analytics` |
   | Dashboard / Overview       | `layout-dashboard`, `dashboard`, `home`       |
   | Comments / Reviews         | `message`, `message-circle`, `star`           |
   | Teams / Organizations      | `users-group`, `building`, `hierarchy`        |
   | Roles / Permissions        | `shield-lock`, `lock`, `key`                  |
   | Media / Files / Uploads    | `photo`, `file`, `paperclip`                  |
   | Tags / Labels / Categories | `tag`, `tags`, `bookmark`                     |
   | Email / Notifications      | `mail`, `bell`, `send`                        |
   | Calendar / Events          | `calendar`, `calendar-event`, `clock`         |
   | Invoices / Billing         | `receipt`, `credit-card`, `currency-dollar`   |
   | Geography / Locations      | `map-pin`, `map`, `globe`                     |
   | Tools / Utilities          | `tool`, `tools`, `hammer`                     |
   | External links             | `external-link`, `link`                       |
   | Sign out / Logout          | `logout`, `door-exit`                         |
   | Profile / Account          | `user-circle`, `id-badge`                     |

3. **No match** — if nothing fits well, skip the item. Never force a generic placeholder.

Always verify the chosen name exists in the icons list before using it.

### Step 4: Apply the changes

Edit the initializer, adding `icon: "tabler/outline/{name}"` (or `tabler/filled/{name}`) to each matched item:

- Preserve exact indentation, spacing, and all existing arguments.
- Place `icon:` naturally — before `collapsable:`/`collapsed:` on sections, otherwise appended.
- Do not touch anything outside the menu blocks.
- Leave existing `icon:` values unchanged.

### Step 5: Report

Tell the user:

- Total icons added
- For each item that got an icon: menu item name → icon chosen, with a one-word reason
- Any items skipped because no good match was found

---

## Approach B — Add icons in resource files

### Step 1: Find all resource files

Use Glob to find all Avo resource files, typically at `app/avo/resources/**/*.rb` or `app/avo/resources/*.rb`.

### Step 2: Identify resources without icons

Read each resource file. Check whether the class body already contains `self.icon`. Collect every resource that is missing it.

The resource name is the class name without the `Resource` suffix (e.g. `Avo::Resources::UserResource` → `User`).

### Step 3: Choose icons

Apply the same matching strategy from Approach A Step 3, using the resource name as the concept to match.

### Step 4: Apply the changes

For each matched resource, add `self.icon = "tabler/outline/{name}"` inside the class body, immediately after the class declaration line (or after any existing `self.model_class` / `self.label` declarations if present):

```ruby
class Avo::Resources::UserResource < Avo::BaseResource
  self.icon = "tabler/outline/users"
  # ... rest of resource
end
```

- Preserve exact indentation and all existing content.
- Do not add `self.icon` if one already exists.
- One edit per file.

### Step 5: Report

Tell the user:

- Total icons added
- For each resource that got an icon: resource name → icon chosen, with a one-word reason
- Any resources skipped because no good match was found
