---
title: "feat: Themes — create, pick, and ship as gems"
type: feat
status: active
date: 2026-09-03
deepened: 2026-09-04
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
brand assets) that Avo discovers, lists in the appearance picker, remembers per
browser or per user, and that can ship in core, live in `app/avo/themes/`, or
come from a gem.

Themes work on **core Avo only**. Add-ons already consume `var(--color-*)`
tokens (see `.claude/rules/gem-css.md`), so a theme that redefines the tokens
re-skins every add-on for free. No add-on changes are planned or needed.

The design reuses the appearance system's existing mechanics wherever one
exists — `<html>` classes, the pre-paint script, cookie/database persistence,
the lock list, the picker partials, the `appearance` Stimulus controller — so a
theme is "one more dimension" of appearance, not a parallel system.

Decisions taken with the user on 2026-09-04 are marked **[decided]** and are
no longer open. The earlier "Decisions to confirm" section is gone; what
remains open is under "Open questions".

## Goals

- One person can create a theme in under five minutes: one generator, one CSS
  file, no build step, visible in the picker after a restart.
- Themes ship as plain gems with no Avo-side registry, license, or approval:
  `gem "avo-coastal_theme"` in the Gemfile is the entire install. The generator
  produces that gem, so "ship it" is one flag, not a docs recipe.
- Core ships a set of built-in themes so every install has a picker full of
  looks on day one, and the docs' agent prompts have real examples to point at.
- A theme can override partials and brand assets (logo, favicon, placeholder,
  chart colors) in addition to CSS, and those overrides apply **only while the
  theme is active**, per user.
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
- A theme forcing the color scheme. **[decided]** Every theme styles both
  schemes; the scheme picker always works. A dark-native look authors a light
  block anyway (see "Built-in themes").
- Changing Avo's Tailwind build. Theme CSS is served as-is, like
  `avo-overrides.css`.

## What a theme is

| Part              | Required | Where (local theme)                                        | Purpose                                                       |
| ----------------- | -------- | ---------------------------------------------------------- | ------------------------------------------------------------- |
| Theme class       | yes      | `app/avo/themes/coastal.rb`                                | Identity, metadata, and the knobs below                       |
| Stylesheet        | yes      | `app/assets/stylesheets/avo/themes/coastal.css`            | CSS variable overrides scoped to `.avo-theme-coastal`         |
| Partial overrides | no       | `app/views/avo/themes/coastal/avo/partials/_logo.html.erb` | Replace any Avo partial while the theme is active             |
| Brand assets      | no       | `app/assets/images/avo/themes/coastal/…`                   | Logo, favicon, placeholder, backgrounds, fonts the theme uses |

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
  # self.appearance = {                               # brand assets applied while active; default {}
  #   logo: "avo/themes/coastal/logo.svg",
  #   logo_dark: "avo/themes/coastal/logo-dark.svg",
  #   favicon: "avo/themes/coastal/favicon.ico",
  #   placeholder: "avo/themes/coastal/placeholder.svg",
  #   chart_colors: %w[#2A9D8F #E9C46A #F4A261 #264653]
  # }
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
   preview instant and switching free of a reload (unless partials or brand
   assets change, see below). It also lets the picker render a live preview
   tile for nothing: an element carrying `avo-theme-coastal` resolves the
   theme's own tokens, so no theme ever declares preview colors in Ruby. The
   second dark selector (`.dark .avo-theme-coastal`) exists for that tile.
2. **Inside `@layer base`. [decided]** This is the layer
   `Appearance#brand_css_overrides` already uses, and for the same reason:
   Avo's defaults live in `@layer theme` (below), the user-pickable
   `.neutral-theme-*` / `.accent-theme-*` classes live in `@layer components`
   (above). A theme is therefore "a brand you can install": it replaces the
   defaults, and a user's neutral/accent pick still wins on top of it. A theme
   that wants the whole palette to itself sets `self.lock = [:neutral, :accent]`
   and the pickers disappear — it does not fight the cascade.

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

**[decided]** The theme's directory goes **ahead of `app/views`**, so a theme's
partial beats one the app ejected. Choosing the theme is the more specific
intent; an app that wants to customize a themed partial ejects it *into the
theme* (`--theme`, below).

This is per request, which is the whole reason theme selection must reach the
server (see Persistence). It is also why switching **to or from** a theme that
has a `views` directory or an `appearance` hash does a Turbo visit after
persisting, while a CSS-only switch just swaps the class.

Authors get theme partials the way they get app ones — the eject generator
grows a `--theme` option:

```bash
rails g avo:eject --partial :logo --theme coastal
# → app/views/avo/themes/coastal/avo/partials/_logo.html.erb
```

### Brand assets

**[decided]** `self.appearance` is a Hash of the asset-ish `config.appearance`
keys — `logo`, `logo_dark`, `logomark`, `logomark_dark`, `favicon`,
`favicon_dark`, `placeholder`, `chart_colors` — merged over the configured
appearance while the theme is active. A company theme is where this earns its
place: the whole brand, colors and marks, in one installable unit. The
palette keys (`neutral`, `accent`, `neutral_colors`, `accent_colors`, `scheme`,
`lock`, `persistence`, `themes`, `theme`) are rejected with an `ArgumentError`
at boot: colors belong in the stylesheet, and the rest is the host's.

A `current_appearance` helper returns the merged view; `_logo`, `_appearance`
(favicon), the placeholder, and the chart color bridge read from it instead of
from `Avo.configuration.appearance` directly.

Webfonts and images the theme references ship in the gem's `app/assets/` and
are referenced by asset path from the CSS (`url()` through
`asset_path`-friendly relative URLs) or `@font-face`. That is a docs note plus
one line about `font-src` under a strict CSP, not code.

## Where themes come from

Three sources, one registry, keyed by theme id.

| Source   | How it is found                                                                                   | Example                                              |
| -------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Built-in | Core's own classes under `Avo::BuiltinThemes::*`, always registered first                          | `Avo::BuiltinThemes::Coastal`                        |
| Local    | `Rails.autoloaders.main.eager_load_namespace(Avo::Themes)` at boot, same as resources and actions  | `app/avo/themes/ocean.rb` → `Avo::Themes::Ocean`     |
| Gem      | The gem's engine requires its theme class; `Avo::BaseTheme.descendants` picks it up               | `avo-ocean_theme` → `Avo::OceanTheme::Theme`         |

`Avo.theme_manager` is built inside `Avo.boot` after the `:avo_boot` hook (so
gems have registered) and exposes `all`, `find(id)`, `ids`, `installed?(id)`.
Two themes with the same id raise at boot with both class names in the message —
a silent "last one wins" is exactly how a gem's theme would shadow a local one
without anyone noticing. Built-ins take part in that check too: a host cannot
define its own `coastal`, it names it something else.

Built-ins live under `Avo::BuiltinThemes`, not `Avo::Themes`, for the same
reason gems do not use the container (next section): `Avo::Themes::*` belongs
to the host app.

### Built-in themes [decided]

Core ships thirteen themes. "Paper" is Avo's stock look given a name, so the
picker reads as peers ("Paper, Coastal, Midnight"), never "Default". It has no
stylesheet — the defaults in `variables.css` *are* Paper — and the class
`avo-theme-paper` is still emitted so the JS always finds exactly one theme
class on `<html>`.

| Order | Id           | Title      | Light block                 | Notes                                                   |
| ----- | ------------ | ---------- | --------------------------- | ------------------------------------------------------- |
| 1     | `paper`      | Paper      | is the light default        | The stock look. No stylesheet                          |
| 2     | `coastal`    | Coastal    | authored                    | Sand neutrals, sea-glass and deep-ocean accents         |
| 3     | `rose`       | Rose       | authored                    | Warm blush neutrals, rich rose accent                   |
| 4     | `sunset`     | Sunset     | authored                    | Dusk purples, magenta-to-orange accents                 |
| 5     | `midnight`   | Midnight   | authored                    | Cool near-black surfaces, electric indigo accent        |
| 6     | `monokai`    | Monokai    | derived                     | Charcoal ground; yellow, magenta, cyan, green accents   |
| 7     | `dracula`    | Dracula    | derived                     | Purple-grey ground, pink and purple accents. MIT spec   |
| 8     | `solarized`  | Solarized  | official (Solarized Light)  | One 16-color palette, real light/dark pair. MIT         |
| 9     | `nord`       | Nord       | derived                     | Arctic blue-grey ground, frost accents. MIT             |
| 10    | `gruvbox`    | Gruvbox    | official (Gruvbox Light)    | Retro warm browns and olive, orange accent. MIT         |
| 11    | `one_dark`   | One Dark   | official (One Light)        | Blue-grey ground, blue and purple accents. MIT          |
| 12    | `catppuccin` | Catppuccin | official (Latte / Mocha)    | Pastel palette. MIT                                     |
| 13    | `tokyo_night`| Tokyo Night| official (Day / Night)      | Deep navy, soft purple and cyan accents. MIT            |

The first five are Avo's own. The last eight are editor palettes; **[decided]**
where the upstream project publishes a light variant we use it, and where it
does not (Monokai, Dracula, Nord) the light block keeps the accents and puts
them on a light ground of the same hue family. Editor themes are dark-native,
so their dark block is the faithful one and the light block is the courtesy.

Built-ins compile into **one stylesheet, `avo/themes.css`**, linked in the
theme slot of the layout (next section) — not into `avo/application.css`. The
distinction matters: `application.css` renders before the inline brand
override, and a built-in theme inside it would lose to a configured brand at
equal specificity. In its own file, in the theme slot, it wins as every other
theme does. Thirteen themes of forty-odd declarations in two schemes is a few
kilobytes minified, cacheable, one request.

Ids use underscores (`one_dark`) and the class uses the id verbatim
(`avo-theme-one_dark`) so nothing maps between the two.

**Attribution.** The editor palettes are reused under their licenses (MIT for
Dracula, Solarized, Nord, Gruvbox, One Dark, Catppuccin, Tokyo Night; the
classic Monokai values are the freely reused 2006 palette, not the commercial
Monokai Pro). Each built-in class carries a `self.attribution` line rendered
nowhere in the UI, and `NOTICE` in the gem lists them. Names are used
descriptively to identify the palette.

### Ordering and the offered list [decided]

The picker is a **flat list** in this order: built-ins in the table order, then
installed themes (local and gems) by title. `config.appearance[:themes]`
replaces that list with the given ids in the given order, and it may omit
`paper`; when it does, `config.appearance[:theme]` must name one of the listed
ids, and the fallback in "Selection" below lands on the first listed theme
rather than on Paper.

### Gem naming [decided]

Field gems set the precedent: `avo-money_field`, `avo-rhino_field`. Theme gems
follow it: **`avo-<name>_theme`**, namespace `Avo::<Name>Theme`, theme class
`Avo::<Name>Theme::Theme`, id `<name>`.

This is what `.claude/rules/avo-dsl-naming.md` requires — a gem must not define
`Avo::Themes::Ocean`, because that is the constant a host app's
`app/avo/themes/ocean.rb` would own, and Zeitwerk would either reopen or
refuse it. The registry is keyed by **id**, not class, so the gem's
`Avo::OceanTheme::Theme` and a host's `Avo::Themes::Ocean` are the same
theme as far as the picker is concerned (and collide at boot, loudly, as above).

The gem is a minimal Rails engine, the shape every field gem already has:

```
avo-ocean_theme/
├── avo-ocean_theme.gemspec            # depends on avo >= 4.x
├── lib/avo/ocean_theme.rb             # requires engine + theme
├── lib/avo/ocean_theme/engine.rb      # precompile manifest (Sprockets), nothing else
├── lib/avo/ocean_theme/theme.rb       # Avo::OceanTheme::Theme < Avo::BaseTheme
├── app/assets/stylesheets/avo/themes/ocean.css
├── app/assets/config/avo-ocean_theme_manifest.js
├── app/assets/images/avo/themes/ocean/  # optional logo, favicon, backgrounds, fonts
├── app/views/avo/themes/ocean/        # optional partial overrides
└── README.md                          # install line + screenshot
```

Propshaft serves engine assets with no registration; Sprockets needs the
manifest added to `precompile`, which the engine template does. The theme's
stylesheet is linked by Avo's layout (below), so the gem never touches
`Avo.asset_manager` — that would load it in the wrong slot.

**[decided]** One reference theme is published as a real gem from `external/`
so the docs can show a genuine install line and the gem path is exercised
outside the test suite. It must be a look that is *not* a built-in; the name is
open (see "Open questions").

## Rendering and the cascade

The layout's `<head>` order becomes:

```
avo/dependencies
plugin stylesheets            (Avo.asset_manager — add-ons)
avo/application               (declares the layer order: theme, base, components, utilities)
appearance_overrides partial  (inline @layer base :root {…} from config.appearance brand colors)
avo/themes                    ← new: the thirteen built-ins, one file
theme stylesheets             ← new: one <link> per installed local/gem theme
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

### Pitfall: custom properties resolve where they are declared

On `<html>` the trick is sound: the theme class and `:root` are the same
element, so a derived default such as
`--color-sidebar-background: var(--color-background)` re-evaluates with the
theme's `--color-background`. On any *other* element carrying a theme class —
the picker's preview tile — it is not: `--color-sidebar-background` was
computed on `<html>` and is inherited already resolved, so the tile would show
Paper's sidebar under Coastal's tokens.

The fix is small and local. The tile's own stylesheet re-declares the derived
chain (`--color-sidebar-background`, `--color-navbar-background`,
`--color-main-content-background`, `--color-row-bg`, and the `.dark` variants)
on `.theme-tile`, **inside `@layer theme`** — the same layer as Avo's defaults —
so a theme that sets one of them explicitly in `@layer base` still wins, and a
theme that sets only primitives sees the chain re-derived from its primitives.
The generator's CSS template does not need to know any of this.

## Selection and persistence

`current_theme` joins `current_neutral` / `current_accent` / `current_scheme` in
`ApplicationHelper`, with the same resolution order:

1. `appearance.lock` includes `:theme` → the configured `appearance.theme`.
2. `persistence: :database` → `Avo::Current.appearance_settings[:theme]`;
   otherwise the `avo.theme` cookie.
3. `appearance.theme` from config.
4. The first offered theme (Paper unless `themes:` reordered or dropped it).

A value is honored only if `Avo.theme_manager.installed?(value)` **and** it is
in the offered list; anything else falls through. The cookie is user-controlled
input, so the check is the whitelist and there is no parsing — the same trust
boundary the sidebar-width cookie documents.

**Cookie, not localStorage.** The brief left this open. Two things decide it:
partial overrides and brand assets are server-rendered and the server needs the
value before rendering, and the first paint already gets its theme class from
the server (`html_theme_classes`) with the pre-paint script in
`_pre_head.html.erb` only reconciling cookie overrides for cached pages.
localStorage never reaches the server, so it could power CSS-only themes and
nothing else. The cookie is named `avo.theme` under `Avo::COOKIES_KEY`, like
`avo.sidebar.width`; the legacy unprefixed `theme` cookie already means
"neutral" and is left alone.

Database persistence adds `:theme` to the settings hash — `load_settings` may
return it, `save_settings` receives it, and `AppearanceSettingsController`
permits it. Apps that already persist to the database get theme persistence
without a migration (the column is JSON).

`window.Avo.configuration.appearance` gains `theme`, `themes` (offered ids, in
order), `themeLocked`, and a `themesNeedingVisit` list (themes with views or an
appearance hash) so the controller knows when a switch needs a visit.

## Picker

The theme section joins the existing switcher, in both layouts:

- **Dropdown panel** (`_switcher_dropdown.html.erb`): a "Theme" section above
  Neutrals, rendered whenever `:theme` is not locked (with thirteen built-ins
  there is always something to pick). Rows use the neutral-option pattern:
  preview tile, label, `mouseenter` preview, `mouseleave` revert, click to set.
  The list is flat and in the offered order; with the built-ins alone it is
  thirteen rows, so the section scrolls inside the panel past roughly eight.
- **Inline pill** (`_switcher_inline.html.erb`): a "Theme" popover pill before
  the neutral pill, showing the active theme's title, same structure as the
  neutral popover, same rows.

**[decided]** The preview is a **mini window tile**, not a dot: an element
carrying `theme-tile avo-theme-<id>` with three bands — a navbar strip in
`var(--color-navbar-background)`, a sidebar column in
`var(--color-sidebar-background)`, a content area in
`var(--color-main-content-background)` — and an accent dot in
`var(--color-accent)`. It shows what a theme does to *surfaces*, which a
single swatch hides, and it costs no per-theme CSS (see the pitfall above for
the one rule that makes it correct). In the current scheme, because
`.dark .avo-theme-<id>` applies. Roughly 40×28px in the rows.

`appearance_controller.js` gains `setTheme`/`previewTheme`/`revertTheme` for the
theme dimension (the existing methods with those names are the neutral picker's
and get renamed to `setNeutral`/… in the same change, with the old names kept as
aliases so ejected partials keep working), `applyThemeClass` swapping
`avo-theme-*` on `<html>`, and the persist-then-maybe-visit step. A
`cycleTheme` hotkey is cheap once that exists and follows the neutral/accent
ones.

Strings: `avo.appearance.themes` ("Theme"), `avo.appearance.theme_picker`, and
the thirteen built-in titles under `avo.appearance.themes_list.*` in core's 19
locales (editor names stay as-is in every locale; "Paper", "Coastal", "Rose",
"Sunset", "Midnight" translate). Installed themes' titles come from the class;
gems ship English, and an author who wants translations passes an `I18n.t`
call.

## Configuration

```ruby
# config/initializers/avo.rb
config.appearance = {
  theme: :coastal,                          # default theme (Symbol); must be offered
  themes: [:paper, :coastal, :monokai],     # offered list and order; default: every installed theme
  lock: [:theme]                            # LOCKABLE grows to [:scheme, :neutral, :accent, :theme]
}
```

`theme`/`themes` are validated against the registry lazily (first request, in
the helper), not in `Appearance#initialize` — the initializer runs before gems
have registered. `avo.tt` documents all three, with the built-in ids listed in
the comment so a host can trim the list without opening the docs.

## Generators

**`rails g avo:theme ocean`** — a local theme:

- `app/avo/themes/ocean.rb` (manifest, derived defaults commented)
- `app/assets/stylesheets/avo/themes/ocean.css` (full commented token template)
- prints: restart the server, open the picker, and the eject `--theme` command.

**`rails g avo:theme ocean --gem [--path ../]`** — the same theme as a
publishable gem, laid out as in "Gem naming" above, plus a README with the
install line and `gem build` / `gem push` steps, `NOTICE`, and a printed
`Gemfile` line using `path:` for local development. **[decided]** Ships in
phase 1 with everything else; without it "create a gem" is a docs page listing
seven manual steps, which is what `plugins.md` does today and why nobody does
it.

**`rails g avo:eject --partial :logo --theme ocean`** — copies Avo's partial
into the theme's views directory instead of `app/views/`.

## Testing

- **Unit**: `Avo::BaseTheme` derived defaults (`id`, `stylesheet`, `views` nil
  when absent, `appearance` key validation); `ThemeManager` discovery from a
  fixture theme, duplicate-id raise (including against a built-in), the
  thirteen built-ins present and in order, `themes:` ordering and omission of
  `paper`; `Appearance` accepts `theme`/`themes`/`lock: [:theme]` and rejects
  non-Symbols.
- **Built-ins**: every built-in stylesheet block declares the required token
  set in both schemes (a parsed-CSS spec against a list on `BaseTheme`), and a
  system spec walks all thirteen asserting the computed contrast of
  `--color-content` on `--color-primary` is at least 4.5:1 in light and dark —
  a derived light block that drifts below AA fails here, not in a customer's
  screenshot.
- **Request**: `<html>` class from cookie, database settings, config default,
  lock, and the offered-list fallback; unknown or un-offered cookie value
  ignored; `avo/themes` and theme `<link>`s emitted after `appearance_overrides`
  and before `avo-overrides`; view path prepended so a fixture theme's `_footer`
  renders only when active and ahead of an app-ejected copy; a fixture theme's
  `appearance[:logo]` used by `_logo` only when active; `PATCH
  appearance_settings` accepts `theme`.
- **System**: picker lists themes with tiles whose bands resolve the theme's
  own tokens (the pitfall above, proven); hover previews and reverts; click
  persists and survives reload; switching to a theme with views triggers a visit
  and shows its partial; computed-style assertion (the pattern in
  `spec/system/avo/group_2/tags_spec.rb`) that `--color-accent` on `<body>`
  resolves to the theme value and that picking a neutral afterwards still
  changes `--color-avo-neutral-500` — the cascade table, proven in a browser.
- **Generators**: file assertions for both generator modes; the dummy app
  carries one **gem-shaped** fixture theme under `spec/dummy/vendor/` loaded
  via `path:` so the gem discovery path is exercised by every request spec, not
  just described.

## Docs and skills

- **New** `docs/4.0/themes.md` (guide: pick a built-in, create one, override
  partials and brand assets, ship as a gem, install one) and
  `docs/4.0/themes-api.md` (the theme class attributes, the three `appearance`
  keys, the built-in table, generator flags) — the guide+reference pair
  `AGENTS.md` asks for above three options. The built-in table gets light and
  dark screenshots via the `docs-screenshots` flow.
- **Update** `theming.md` (a new ladder row and a "let an agent do it" prompt
  that targets the generator, plus the existing three prompts pointing at the
  built-ins they now duplicate), `appearance.md` / `appearance-api.md`
  (`theme`, `themes`, lock, the `:theme` settings key), `eject-views.md`
  (`--theme`), `plugins.md` (point theme authors at the theme generator instead
  of the seven-step plugin recipe), and the 4.0 sidebar.
- **Skill**: `lib/avo/skills/avo-branding-appearance/SKILL.md` gains the theme
  workflow as the answer to "give the admin a coastal theme" (today it edits
  `avo-overrides.css`; tomorrow it sets `theme: :coastal` or generates one).
  Run `ws audit-skills`.
- `avo.tt` gains the three keys and the built-in id list.
- `NOTICE` gains the editor palette attributions.

## Phasing

| Phase | Ships                                                                                                                                                              |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1     | Layered `:root` knobs; `BaseTheme` + manager; thirteen built-ins in `avo/themes.css`; config keys; layout slots; helper + cookie/database; picker with tiles + JS; `avo:theme` (local and `--gem`); `eject --theme`; brand-asset merge; docs; skill |
| 2     | The published reference gem from `external/`; docs screenshots of every built-in                                                                                   |
| 3     | Only on demand: a Themes page on avohq.io; a curated pack gem if the built-in list ever needs trimming                                                              |

Phase 1 is one avo release, and a large one: the built-in palettes are the
bulk of the authoring work and the part that needs eyes. Phase 2 needs nothing
from core beyond phase 1.

## Open questions

- **The reference gem's look and name.** It must not be a built-in. Candidates:
  Sepia, Forest, Slate-on-brass. Pick one and it becomes `avo-<name>_theme`.
- **Fonts helper.** `@font-face` by hand plus a docs note covers phase 1. If
  two published themes both ship fonts, a `self.fonts` helper that emits the
  faces and the CSP hint is worth adding.
- **Editor theme fidelity.** Upstream palettes name colors for syntax, not for
  admin chrome; mapping "string green" to "success" is taste. The first pass
  is authored once and reviewed as a batch against screenshots, and the
  contrast spec is the floor.

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
