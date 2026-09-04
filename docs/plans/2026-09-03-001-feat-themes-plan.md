---
title: "feat: Themes — create, pick, and ship as gems"
type: feat
status: phase-1-implemented
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
- An admin can build a theme visually, in the running app, and keep it across
  deploys — the Theme Studio, below.

## Non-goals

- Overriding ViewComponents from a theme. Components are Ruby classes with
  compiled sidecar templates; view-path resolution cannot swap them. Themes
  override **partials** only. Component customization stays an app-level
  `avo:eject --component` concern.
- A themes marketplace or gallery on avohq.io, licensing, or paid themes.
  Themes are MIT-or-whatever gems the author publishes to rubygems.org.
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

Four sources, one registry, keyed by theme id.

| Source   | How it is found                                                                                   | Example                                              |
| -------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Built-in | Core's own classes under `Avo::BuiltinThemes::*`, always registered first                          | `Avo::BuiltinThemes::Coastal`                        |
| Local    | `Rails.autoloaders.main.eager_load_namespace(Avo::Themes)` at boot, same as resources and actions  | `app/avo/themes/ocean.rb` → `Avo::Themes::Ocean`     |
| Gem      | The gem's engine requires its theme class; `Avo::BaseTheme.descendants` picks it up               | `avo-ocean_theme` → `Avo::OceanTheme::Theme`         |
| Stored   | Rows of the host's `AvoTheme` model, saved by the Theme Studio; read per request (see below)       | slug `acme`, rendered inline                         |

`Avo.theme_manager` is built inside `Avo.boot` after the `:avo_boot` hook (so
gems have registered) and exposes `all`, `find(id)`, `ids`, `installed?(id)`.
Stored themes are the one dynamic source: the manager merges them in per
request (memoized on `Avo::Current`, one query keyed on the store's newest
`updated_at`), so a theme saved in the studio is in the picker on the next
page load without a restart.
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

`appearance_controller.js` gains `setAppearanceTheme` / `previewAppearanceTheme`
/ `revertAppearanceTheme` / `cycleAppearanceTheme` for the theme dimension. The
existing `setTheme` / `previewTheme` / `revertTheme` are the neutral picker's;
Avo's own partials now call them as `setNeutral` / `previewNeutral` /
`revertNeutral`, and the old names stay as aliases so ejected partials keep
working. `applyAppearanceThemeClass` swaps `avo-theme-*` on `<html>`, and the
persist step returns the request promise so a switch that needs a re-render
visits the page once the pick is saved. No hotkey ships in phase 1: `cycleAppearanceTheme`
exists, and binding it is a one-line follow-up once a free key is agreed.

Strings: `avo.appearance.themes` ("Themes") and `avo.appearance.theme_picker`
in core's 19 locales. The neutral section's label, which read "Theme" before
there were themes, becomes "Neutral" in every locale. Every theme's title,
built-ins included, comes from the class — a built-in title is a name
("Dracula", "Paper"), not a phrase, and stays as-is in every locale. A theme
author who wants a translated title passes an `I18n.t` call.

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

## Theme Studio [decided]

A visual editor for themes, inside the running admin. Because a theme is
custom properties on `<html>`, the two expensive halves of an editor — live
preview and apply — cost nothing: the studio sets a property with
`documentElement.style.setProperty` and the whole admin behind the panel
repaints. What has to be built is a form over the token catalog, a renderer,
and a store.

### One token catalog

`Avo::Themes::TOKENS` is a Ruby list — name, group, kind (`color`, `length`,
`boolean`, `duration`), label, description, and which token it derives from
when unset — and it feeds four things that must not drift:

| Consumer                          | Uses the catalog for                                       |
| --------------------------------- | ---------------------------------------------------------- |
| `rails g avo:theme` CSS template  | the commented-out list of every token, grouped             |
| The studio's form                 | groups, inputs, "inherits from …" state, reset             |
| `Avo::Themes::Renderer`           | turning a tokens hash into the CSS block for a theme       |
| The built-in token spec           | the required set each built-in must declare                |

`Renderer` is the single place that knows what a theme stylesheet looks like:
`tokens` (a Hash of `light:` / `dark:` maps) in, the `@layer base {
.avo-theme-<id> { … } .avo-theme-<id>.dark, .dark .avo-theme-<id> { … } }`
text out. The generator writes its output to a file with every line commented;
the studio's file store writes it uncommented; the stored-theme path renders it
inline. Three outputs, one shape.

### Where it lives and who can open it [decided]

A tool page at **`/avo/themes`** — an index of every installed theme with
its preview tile, from which a theme opens in the editor or is duplicated as
the starting point of a new one — linked from the theme section of the picker
when the current user may open it. Available in **every environment**, gated
by a block:

```ruby
config.appearance = {
  studio: {
    enabled: true,                                   # default: Rails.env.development?
    authorize: -> { current_user&.admin? }           # default: -> { Rails.env.development? }
  }
}
```

The block runs through `Avo::ExecutionContext` with `current_user`, like every
other appearance block. In development with no configuration the studio is
simply on. In production it is off until both keys are set, and the
`authorize` block is a trust boundary: whoever passes it can change what every
admin sees.

### Storage: rows, not files [decided]

Production has no writable app directory, and a file written into a container
is gone at the next deploy. So the studio saves **stored themes**:

```bash
rails g avo:theme_store
# → app/models/avo_theme.rb, db/migrate/…_create_avo_themes.rb
```

| Column        | Type    | Holds                                                        |
| ------------- | ------- | ------------------------------------------------------------ |
| `slug`        | string  | The theme id, unique                                          |
| `title`       | string  | Picker label                                                  |
| `description` | text    |                                                               |
| `base`        | string  | The theme it was started from, for "reset to base"            |
| `tokens`      | jsonb   | `{ "light": { "--color-accent": "#2a9d8f", … }, "dark": { … } }` |
| `appearance`  | jsonb   | `chart_colors`, and which attachments are set                 |

plus `has_one_attached` for `logo`, `logo_dark`, `logomark`, `logomark_dark`,
`favicon`, `favicon_dark`, `placeholder`. Rows live in the app's database and
attachments in Active Storage's configured service, both of which outlast a
deploy — the point of the model. Core stays migration-free, as it is for the
media library: the generator puts the model in the host app.

Two consequences of storing **tokens, not CSS**:

- No free-text CSS ever reaches the database or the page. The renderer emits
  only catalog tokens with validated values (a color parses as a color, a
  length as a length), so the `authorize` block guards taste, not injection.
- A stored theme reopens in the studio exactly as it was saved, with the
  "inherits" state intact — there is no CSS to parse back.

Stored themes render as one inline `<style>` per theme in the theme slot of
the layout, nonce'd, cached in `Avo.cache_store` keyed on `updated_at`. No
asset pipeline, no extra request, and the cascade table holds because the
renderer wraps them in `@layer base` like everything else.

In development the studio can **also** save to a file — a local theme in
`app/avo/themes/` and `app/assets/stylesheets/avo/themes/`, the same output
as the generator — for a theme that is meant to be committed and shipped.
The Save menu offers "Save to database" when the store exists and "Save as
file" in development, and says which it did.

Brand assets on a stored theme are blobs, so `current_appearance` learns to
hand back a blob as well as an asset path, and `_logo`, `_appearance`
(favicon) and the placeholder resolve either through the existing routable
blob helper. In development's file save, uploads are copied into the theme's
asset directory instead.

### What the studio edits [decided]

- **Color tokens**, light and dark, in the catalog's groups: foundations,
  accent, semantic, chrome. The light/dark tab also switches the page's scheme
  so the preview shows what is being edited.
- **Radii and motion knobs**: card radius, navbar notch (radius, enabled,
  alignment), main content radius, the three speeds.
- **Brand assets**: file pickers for the seven attachments and a chart color
  list.

Each token row shows its value, whether it is inherited (from the base theme
or from the token it derives from), and a reset. Only overridden tokens are
saved, so an exported theme pins what its author chose and nothing else.

Browsers' color input speaks hex; Avo's tokens are oklch. The studio converts
both ways in JS (roughly fifty lines) and stores what the user picked.

Not in the first version: a live contrast readout (the built-in contrast spec
stays the floor), editing partials, and exporting a gem from the UI.
"Duplicate as file theme, then `--gem`" is the path from a studio theme to a
gem, and it is two commands.

### Effort

The studio is roughly the size of the core theme feature again: a controller
and page, a Stimulus controller of a few hundred lines, the renderer, the
store and its generator, blob-aware appearance helpers, and specs. It is why
it is phase 2, not phase 1, and why the catalog and renderer are built in
phase 1 even though the generator alone would not need them as classes.

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
- **Generators**: file assertions for both generator modes and for
  `avo:theme_store`; the dummy app carries one **gem-shaped** fixture theme
  under `spec/dummy/vendor/` loaded via `path:` so the gem discovery path is
  exercised by every request spec, not just described.
- **Studio**: the renderer round-trips a tokens hash to the exact CSS the
  generator emits; invalid values are rejected per kind; the `authorize` block
  gates the page (request spec, 403 without it in production); saving creates
  a stored theme that appears in the picker on the next request without a
  restart; a stored theme's logo blob renders in `_logo` while active; the
  system spec edits the accent in the studio and asserts the computed value on
  `<body>` changes before saving, then persists after.

## Docs and skills

- **New** `docs/4.0/themes.md` (guide: pick a built-in, create one, build one
  in the studio, override partials and brand assets, ship as a gem, install
  one) and
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
| 2     | Theme Studio: catalog-driven form, renderer, `avo:theme_store`, stored themes in the picker, blob-aware brand assets; the published reference gem from `external/`; docs screenshots of every built-in |
| 3     | Only on demand: a live contrast readout in the studio; a Themes page on avohq.io; a curated pack gem if the built-in list ever needs trimming                        |

Phase 1 is one avo release, and a large one: the built-in palettes are the
bulk of the authoring work and the part that needs eyes. Phase 2 is a second
release of about the same size, almost all of it the studio; it builds on
phase 1's catalog and renderer and needs nothing else from core.

## Open questions

- **The reference gem's look and name.** It must not be a built-in. Candidates:
  Sepia, Forest, Slate-on-brass. Pick one and it becomes `avo-<name>_theme`.
- **Fonts helper.** `@font-face` by hand plus a docs note covers phase 1. If
  two published themes both ship fonts, a `self.fonts` helper that emits the
  faces and the CSP hint is worth adding.
- **Studio in production and Turbo.** A stored theme with partials is not
  possible (rows hold tokens and assets, not ERB), so a studio switch never
  needs a visit — unless the theme has brand assets, which re-render the logo.
  Confirm the visit-on-switch rule stays "views or appearance" and does not
  grow a third case.
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
