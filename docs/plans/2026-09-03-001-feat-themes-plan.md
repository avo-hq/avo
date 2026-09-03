---
title: "feat: Themes — create, pick, and ship as gems"
type: feat
status: draft
date: 2026-09-03
---

# feat: Themes — create, pick, and ship as gems

## Overview

Today Avo has two theming surfaces and nothing between them:

- `config.appearance` — one brand per install (logos, a neutral, an accent), plus
  a picker that lets each user pick a preset neutral/accent/scheme, remembered in
  a cookie or the database.
- `avo-overrides.css` / an ejected `:head` partial — one unnamed, always-on pile
  of CSS variable overrides per app.

There is no way to give a look a **name**, offer several looks side by side, let
a user **pick** one, or hand a look to another app. "Themes" is that missing
layer: a named, self-contained bundle (a stylesheet, optionally partials and
assets) that Avo discovers, lists in the appearance picker, remembers per
browser or per user, and that can live in `app/avo/themes/` or in a gem.

Themes work on **core Avo only**. Add-ons already consume `var(--color-*)`
tokens (see `.claude/rules/gem-css.md`), so a theme that redefines the tokens
re-skins every add-on for free. No add-on changes are planned or needed.

The design reuses the appearance system's existing mechanics wherever one
exists — `<html>` classes, the pre-paint script, cookie/database persistence,
the lock list, the picker partials, the `appearance` Stimulus controller — so a
theme is "one more dimension" of appearance, not a parallel system.

## Goals

- One person can create a theme in under five minutes: one generator, one CSS
  file, no build step, visible in the picker after a restart.
- Themes ship as plain gems with no Avo-side registry, license, or approval:
  `gem "avo-coastal_theme"` in the Gemfile is the entire install.
- A theme can override partials (logo, footer, head, …) in addition to CSS, and
  those overrides apply **only while the theme is active**, per user.
- Users pick a theme from the existing appearance picker, with hover preview,
  and the pick survives reloads (cookie by default, database when the app has
  opted into `persistence: :database`).
- The neutral/accent/scheme pickers keep working on top of a theme unless the
  theme locks them.
- Existing `avo-overrides.css` and `:head` overrides keep their precedence:
  the app always wins over any theme.

## Non-goals

- Overriding ViewComponents from a theme. Components are Ruby classes with
  compiled sidecar templates; view-path resolution cannot swap them. Themes
  override **partials** only. Component customization stays an app-level
  `avo:eject --component` concern.
- A themes marketplace or gallery on avohq.io, licensing, or paid themes.
  Themes are MIT-or-whatever gems the author publishes to rubygems.org.
- A visual theme editor. The authoring surface is CSS (and, per the docs'
  "let an AI agent do it" section, an agent writing that CSS).
- Per-theme JavaScript. A theme that needs behavior is a plugin, not a theme.
- Changing Avo's Tailwind build. Theme CSS is served as-is, like
  `avo-overrides.css`.

## What a theme is

| Part              | Required | Where (local theme)                                   | Purpose                                                        |
| ----------------- | -------- | ----------------------------------------------------- | -------------------------------------------------------------- |
| Theme class       | yes      | `app/avo/themes/coastal.rb`                           | Identity, metadata, and the knobs below                        |
| Stylesheet        | yes      | `app/assets/stylesheets/avo/themes/coastal.css`       | CSS variable overrides scoped to `.avo-theme-coastal`          |
| Partial overrides | no       | `app/views/avo/themes/coastal/avo/partials/_logo.html.erb` | Replace any Avo partial while the theme is active         |
| Assets            | no       | `app/assets/images/avo/themes/coastal/…`              | Backgrounds, fonts, logos referenced from the CSS or partials  |

The theme class is the manifest. It follows the resource/action DSL shape
(`class_attribute`-backed, defaults derived from the class name):

```ruby
# app/avo/themes/coastal.rb
class Avo::Themes::Coastal < Avo::BaseTheme
  self.title = "Coastal"                              # picker label; defaults to id.titleize
  self.description = "Soft sand neutrals, sea-glass accents."
  # self.id = :coastal                                # defaults from the class name
  # self.stylesheet = "avo/themes/coastal"            # asset-pipeline path; default derived from id
  # self.views = root.join("app/views/avo/themes/coastal") # default derived; nil when the dir is absent
  # self.lock = [:neutral, :accent]                   # hide pickers the theme owns; default []
end
```

Everything commented out is a derived default. The generated file shows them so
an author knows the knobs exist, the same way `avo.tt` does for configuration.

### The stylesheet

```css
/* app/assets/stylesheets/avo/themes/coastal.css */
@layer base {
  .avo-theme-coastal {
    --color-avo-neutral-50: oklch(98% 0.01 80);
    /* … all twelve shades … */
    --color-accent: oklch(62% 0.12 200);
    --color-accent-content: oklch(52% 0.12 200);
    --color-accent-foreground: var(--color-white);
    --color-brand-accent: oklch(62% 0.12 200);       /* the picker's "Brand" swatch */
    --color-navbar-background: oklch(30% 0.05 220);
    --radius-card: 1.25rem;
  }

  .avo-theme-coastal.dark,
  .dark .avo-theme-coastal {
    --color-accent: oklch(72% 0.10 200);
    /* … */
  }
}
```

Two choices in that template carry the whole cascade design:

1. **Scoped to a class, not `:root`.** All installed themes load at once and
   only the `<html class>` decides which one applies. That is what makes hover
   preview instant and switching free of a reload (unless partials change, see
   below). It also gives the picker a live swatch for nothing: a `<span
   class="avo-theme-coastal">` resolves the theme's own `--color-accent`, so no
   theme ever declares preview colors in Ruby. The second dark selector
   (`.dark .avo-theme-coastal`) exists for that swatch.
2. **Inside `@layer base`.** This is the layer `Appearance#brand_css_overrides`
   already uses, and for the same reason: Avo's defaults live in `@layer theme`
   (below), the user-pickable `.neutral-theme-*` / `.accent-theme-*` classes live
   in `@layer components` (above). A theme is therefore "a brand you can
   install": it replaces the defaults, and a user's neutral/accent pick still
   wins on top of it. A theme that wants the whole palette to itself sets
   `self.lock = [:neutral, :accent]` and the pickers disappear — it does not
   fight the cascade.

The generated template lists every public token from `variables.css` grouped as
the docs' CSS-variables reference does (foundations light, foundations dark,
accent, semantic, chrome knobs, radii, motion), each commented out. An author —
or an agent — uncomments what they want. Because the file is plain CSS, the
existing "let an AI agent do it" prompts need only one extra sentence: "put it in
the theme the generator created".

### Partial overrides

A theme's `views` directory mirrors Avo's `app/views` tree. When the theme is
active, `Avo::ApplicationController` prepends that directory to the view path
for the request, so `app/views/avo/themes/coastal/avo/partials/_logo.html.erb`
is what `render partial: "avo/partials/logo"` finds — in layouts, partials, and
inside ViewComponents (they render partials through the controller's lookup
context).

This is per request, which is the whole reason theme selection must reach the
server (see Persistence). It is also why switching **to or from** a theme that
has a `views` directory does a Turbo visit after persisting, while a CSS-only
switch just swaps the class.

Authors get theme partials the way they get app ones — the eject generator
grows a `--theme` option:

```bash
rails g avo:eject --partial :logo --theme coastal
# → app/views/avo/themes/coastal/avo/partials/_logo.html.erb
```

## Where themes come from

Three sources, one registry, keyed by theme id.

| Source     | How it is found                                                                                  | Example                                          |
| ---------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------ |
| Local      | `Rails.autoloaders.main.eager_load_namespace(Avo::Themes)` at boot, same as resources and actions | `app/avo/themes/coastal.rb` → `Avo::Themes::Coastal` |
| Gem        | The gem's engine requires its theme class; `Avo::BaseTheme.descendants` picks it up             | `avo-coastal_theme` → `Avo::CoastalTheme::Theme`     |
| Built-in   | None planned for v1. The registry always has a `default` entry (Avo's own look, no stylesheet)  | —                                                |

`Avo.theme_manager` is built inside `Avo.boot` after the `:avo_boot` hook (so
gems have registered) and exposes `all`, `find(id)`, `ids`, `installed?(id)`.
Two themes with the same id raise at boot with both class names in the message —
a silent "last one wins" is exactly how a gem's theme would shadow a local one
without anyone noticing.

### Gem naming

Field gems set the precedent: `avo-money_field`, `avo-rhino_field`. Theme gems
follow it: **`avo-<name>_theme`**, namespace `Avo::<Name>Theme`, theme class
`Avo::<Name>Theme::Theme`, id `<name>`.

This is what `.claude/rules/avo-dsl-naming.md` requires — a gem must not define
`Avo::Themes::Coastal`, because that is the constant a host app's
`app/avo/themes/coastal.rb` would own, and Zeitwerk would either reopen or
refuse it. The registry is keyed by **id**, not class, so the gem's
`Avo::CoastalTheme::Theme` and a host's `Avo::Themes::Coastal` are the same
theme as far as the picker is concerned (and collide at boot, loudly, as above).

The gem is a minimal Rails engine, the shape every field gem already has:

```
avo-coastal_theme/
├── avo-coastal_theme.gemspec          # depends on avo >= 4.x
├── lib/avo/coastal_theme.rb           # requires engine + theme
├── lib/avo/coastal_theme/engine.rb    # precompile manifest (Sprockets), nothing else
├── lib/avo/coastal_theme/theme.rb     # Avo::CoastalTheme::Theme < Avo::BaseTheme
├── app/assets/stylesheets/avo/themes/coastal.css
├── app/assets/config/avo-coastal_theme_manifest.js
├── app/views/avo/themes/coastal/      # optional partial overrides
└── README.md                          # install line + screenshot
```

Propshaft serves engine assets with no registration; Sprockets needs the
manifest added to `precompile`, which the engine template does. The theme's
stylesheet is linked by Avo's layout (below), so the gem never touches
`Avo.asset_manager` — that would load it in the wrong slot.

## Rendering and the cascade

The layout's `<head>` order becomes:

```
avo/dependencies
plugin stylesheets            (Avo.asset_manager — add-ons)
avo/application               (declares the layer order: theme, base, components, utilities)
appearance_overrides partial  (inline @layer base :root {…} from config.appearance brand colors)
theme stylesheets             ← new: one <link> per registered theme, all of them
avo-overrides.css             (app; unlayered, wins everything below :head)
:head partial
color_theme_override, sidebar_width_override
```

Resulting precedence, lowest to highest:

| Layer / position                       | Who                                              |
| -------------------------------------- | ------------------------------------------------ |
| `@layer theme`                         | Avo defaults (`@theme` block, `.dark` defaults)  |
| `@layer base`, earlier                 | `config.appearance` brand colors (`:root`)       |
| `@layer base`, later                   | **Active theme** (`.avo-theme-<id>`)             |
| `@layer components`                    | User's neutral/accent picks                      |
| unlayered                              | `avo-overrides.css`, `:head` partial — the app   |

Theme links sit **after** `avo/application.css` so the layer order is already
declared when the theme's `@layer base` is parsed (a `@layer` seen before the
declaration would be created first, i.e. lowest, and break the table above), and
**after** the brand overrides so a chosen theme beats a configured brand at
equal specificity.

### Prerequisite: layer the `:root` knobs

`variables.css` keeps a handful of knobs in a plain, unlayered `:root` block
(`--navbar-notch-*`, `--main-content-radius`, `--speed-*`,
`--top-navbar-start-notch-align-with-main-content`). Unlayered beats layered
regardless of order, so a theme in `@layer base` could never flatten the navbar
notch. Move that block into `@layer theme { :root { … } }` (the comment there
explains why it is not in `@theme` — that reason does not apply to a plain rule
inside the layer). `color-scheme` and its `.dark` counterpart stay as they are.
Nothing that overrides those knobs today gets weaker: an unlayered override
still wins, and a layered one now wins where it silently lost before.

## Selection and persistence

`current_theme` joins `current_neutral` / `current_accent` / `current_scheme` in
`ApplicationHelper`, with the same resolution order:

1. `appearance.lock` includes `:theme` → the configured `appearance.theme`.
2. `persistence: :database` → `Avo::Current.appearance_settings[:theme]`;
   otherwise the `avo.theme` cookie.
3. `appearance.theme` from config.
4. `default`.

A value is honored only if `Avo.theme_manager.installed?(value)`; anything else
falls through. The cookie is user-controlled input, so the check is the
whitelist and there is no parsing — the same trust boundary the sidebar-width
cookie documents.

**Cookie, not localStorage.** The brief left this open. Two things decide it:
partial overrides are server-rendered and the server needs the value before
rendering, and the first paint already gets its theme class from the server
(`html_theme_classes`) with the pre-paint script in `_pre_head.html.erb` only
reconciling cookie overrides for cached pages. localStorage never reaches the
server, so it could power CSS-only themes and nothing else. The cookie is named
`avo.theme` under `Avo::COOKIES_KEY`, like `avo.sidebar.width`; the legacy
unprefixed `theme` cookie already means "neutral" and is left alone.

Database persistence adds `:theme` to the settings hash — `load_settings` may
return it, `save_settings` receives it, and `AppearanceSettingsController`
permits it. Apps that already persist to the database get theme persistence
without a migration (the column is JSON).

`window.Avo.configuration.appearance` gains `theme`, `themes` (offered ids),
`themeLocked`, and a `themesWithViews` list so the controller knows when a
switch needs a visit.

## Picker

The theme section joins the existing switcher, in both layouts:

- **Dropdown panel** (`_switcher_dropdown.html.erb`): a "Theme" section above
  Neutrals, rendered only when at least one theme besides `default` is offered
  and `:theme` is not locked. Rows use the neutral-option pattern: swatch, label,
  `mouseenter` preview, `mouseleave` revert, click to set.
- **Inline pill** (`_switcher_inline.html.erb`): a "Theme" popover pill before
  the neutral pill, showing the active theme's title, same structure as the
  neutral popover.

The swatch is `<span class="color-scheme-switcher__theme-swatch avo-theme-<id>">`
with `background: var(--color-accent)` and a ring of
`var(--color-avo-neutral-400)`, so it shows the theme's real colors, in the
current scheme, with no per-theme CSS in Avo. The `default` row's swatch carries
no theme class and so shows the brand.

`appearance_controller.js` gains `setTheme`/`previewTheme`/`revertTheme` for the
theme dimension (the existing methods with those names are the neutral picker's
and get renamed to `setNeutral`/… in the same change, with the old names kept as
aliases so ejected partials keep working), `applyThemeClass` swapping
`avo-theme-*` on `<html>`, and the persist-then-maybe-visit step. A
`cycleTheme` hotkey is cheap once that exists and follows the neutral/accent
ones.

Strings: `avo.appearance.themes` ("Theme"), `avo.appearance.theme_picker`,
`avo.appearance.themes_list.default` ("Default") in core's 19 locales. Theme
titles come from the theme class; gems ship English, and an author who wants
translations passes an `I18n.t` call.

## Configuration

```ruby
# config/initializers/avo.rb
config.appearance = {
  theme: :coastal,                       # default theme (Symbol); must be installed
  themes: [:default, :coastal, :midnight], # offered list and order; default: every installed theme
  lock: [:theme]                          # LOCKABLE grows to [:scheme, :neutral, :accent, :theme]
}
```

`theme`/`themes` are validated against the registry lazily (first request, in
the helper), not in `Appearance#initialize` — the initializer runs before gems
have registered. `avo.tt` documents all three.

## Generators

**`rails g avo:theme coastal`** — a local theme:

- `app/avo/themes/coastal.rb` (manifest, derived defaults commented)
- `app/assets/stylesheets/avo/themes/coastal.css` (full commented token template)
- prints: restart the server, open the picker, and the eject `--theme` command.

**`rails g avo:theme coastal --gem [--path ../]`** — the same theme as a
publishable gem, laid out as in "Gem naming" above, plus a README with the
install line and `gem build` / `gem push` steps, and a printed `Gemfile` line
using `path:` for local development. This is the "ship it" half of the feature;
without it "create a gem" is a docs page listing seven manual steps, which is
what `plugins.md` does today and why nobody does it.

**`rails g avo:eject --partial :logo --theme coastal`** — copies Avo's partial
into the theme's views directory instead of `app/views/`.

## Testing

- **Unit**: `Avo::BaseTheme` derived defaults (`id`, `stylesheet`, `views` nil
  when absent); `ThemeManager` discovery from a fixture theme, duplicate-id
  raise, `default` always present, `themes:` ordering; `Appearance` accepts
  `theme`/`themes`/`lock: [:theme]` and rejects non-Symbols.
- **Request**: `<html>` class from cookie, database settings, config default,
  and lock; unknown cookie value ignored; theme `<link>`s emitted after
  `appearance_overrides` and before `avo-overrides`; view path prepended so a
  fixture theme's `_footer` renders only when active; `PATCH appearance_settings`
  accepts `theme`.
- **System**: picker lists themes with swatches; hover previews and reverts;
  click persists and survives reload; switching to a theme with views triggers
  a visit and shows its partial; computed-style assertion (the pattern in
  `spec/system/avo/group_2/tags_spec.rb`) that `--color-accent` on `<body>`
  resolves to the theme value and that picking a neutral afterwards still
  changes `--color-avo-neutral-500` — the cascade table, proven in a browser.
- **Generators**: file assertions for both generator modes; the dummy app
  carries one **gem-shaped** fixture theme under `spec/dummy/vendor/` loaded
  via `path:` so the gem discovery path is exercised by every request spec, not
  just described.

## Docs and skills

- **New** `docs/4.0/themes.md` (guide: create one, override partials, ship as a
  gem, install one) and `docs/4.0/themes-api.md` (the theme class attributes,
  the three `appearance` keys, generator flags) — the guide+reference pair
  `AGENTS.md` asks for above three options.
- **Update** `theming.md` (a new ladder row and a "let an agent do it" prompt
  that targets the generator), `appearance.md` / `appearance-api.md` (`theme`,
  `themes`, lock, the `:theme` settings key), `eject-views.md` (`--theme`),
  `plugins.md` (point theme authors at the theme generator instead of the
  seven-step plugin recipe), and the 4.0 sidebar.
- **Skill**: `lib/avo/skills/avo-branding-appearance/SKILL.md` gains the theme
  workflow as the answer to "give the admin a coastal theme" (today it edits
  `avo-overrides.css`, which stops being the best answer). Run `ws audit-skills`.
- `avo.tt` gains the three keys.

## Phasing

| Phase | Ships                                                                                                                            |
| ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Layered `:root` knobs; `BaseTheme` + manager; config keys; layout slot; helper + cookie/database; picker + JS; `avo:theme` (local); `eject --theme`; docs; skill |
| 2     | `avo:theme --gem`; one published reference theme (`avo-coastal_theme`, in `external/`) that doubles as the docs screenshot and the smoke test for the gem path |
| 3     | Only on demand: theme-provided `logo`/`favicon`, a theme forcing a scheme, a Themes page on avohq.io                             |

Phase 1 is one avo release. Phase 2 needs nothing from core beyond phase 1, so
it can trail by a release without anyone being blocked — a theme gem is just a
gem with a class in it.

## Decisions to confirm

Each of these changes the shape of the work. The recommendation is stated;
silence means it stands.

1. **Picker beats theme, theme can lock.** Theme CSS in `@layer base`; a user's
   neutral/accent pick applies on top; `self.lock` hides pickers the theme
   owns. The alternative — unlayered theme CSS that silently disables the
   pickers — is simpler to author and worse to use.
2. **Gem name `avo-<name>_theme`**, class `Avo::<Name>Theme::Theme`, per the
   field-gem precedent and the DSL naming rule. `avo-theme-<name>` reads better
   on rubygems but maps to `Avo::Theme::<Name>`, which squats a container.
3. **A theme's partial beats an app-ejected partial** while the theme is
   active. The other reading (app always wins, theme partials silently no-op
   when the app ejected the same file) is defensible; pick one and document it.
4. **All installed theme stylesheets load on every page**, not only the active
   one. Buys instant preview and reload-free switching; costs one small
   `<link>` per theme.
5. **Cookie `avo.theme`**, leaving the legacy `theme` cookie (which stores the
   neutral) untouched. Renaming that one is a separate, breaking cleanup.
6. **No theme section when only `default` exists.** An install with no themes
   sees exactly today's picker.

## Open questions

- Should `default` be renamable/hideable — an app that ships a company theme
  and wants it to be the only option today sets `lock: [:theme]`; is that
  enough, or does `themes: [:coastal]` (without `default`) need to work too?
  Leaning yes, it should, with `theme:` then required.
- Does a theme ever need to contribute to `Avo.configuration.appearance`
  (logo, favicon)? Deferred to phase 3 until a real theme asks for it.
- Fonts: a theme gem that ships a webfont needs `@font-face` with an asset
  path and, under a strict CSP, a `font-src` entry. Docs note, or a
  `self.fonts` helper? Docs note for v1.

## References

- `app/assets/stylesheets/css/variables.css` — tokens, layer rationale, the
  unlayered `:root` block
- `lib/avo/configuration/appearance.rb` — `brand_css_overrides` and the layer
  argument this design extends
- `app/helpers/avo/application_helper.rb` — `html_theme_classes`,
  `current_*`, the sidebar-width cookie trust boundary
- `app/views/avo/partials/_pre_head.html.erb` — pre-paint cookie reconciliation
- `app/views/avo/partials/_switcher_dropdown.html.erb`, `_switcher_inline.html.erb`
- `app/javascript/js/controllers/appearance_controller.js`
- `lib/generators/avo/eject_generator.rb` — `TEMPLATES`, `eject_partial`
- `lib/avo/resources/resource_manager.rb` — the discovery pattern the theme
  manager copies
- `.claude/rules/avo-dsl-naming.md`, `.claude/rules/gem-css.md`
- https://docs.avohq.io/4.0/theming.html#let-an-ai-agent-do-it
