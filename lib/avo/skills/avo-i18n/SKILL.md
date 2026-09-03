---
name: avo-i18n
description: Translate and localize the Avo admin — resource, action, and field labels, scope/card/dashboard titles, tab and panel titles, field help/placeholder/include_blank text, save-button labels, the interface language, and right-to-left layout — via `config/locales/avo.<locale>.yml`, `self.translation_key`, and `config.locale`. Use when the user wants to translate the admin to another language (French/Spanish/German/Arabic/…), localize or rename resource/field/action/scope/card/dashboard labels, translate tab or panel titles, make the admin multilingual, support RTL languages, change or force the admin's interface language, show a different label per language, or work out which keys are safe to add under `avo.`.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo i18n (Localization)

Avo rides on Rails' `I18n`, so localizing the admin is mostly YAML plus a handful of translation-key hooks. Avo ships **19 locale files** (`avo.en.yml` and 18 others) **bundled inside the gem** and auto-loads them into `I18n` — so `bin/rails avo:install` does **not** copy them into the app. Two moving parts do all the work: **translation keys** that map a resource/action/field to a spot in the YAML tree (`self.translation_key`, `translation_key:`), and **the active locale** that decides which language renders (`config.locale`, `set_locale`/`force_locale` params). Everything else — the label cascade, RTL, button labels — falls out of those two.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every option/key against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Localization (i18n) guide: https://docs.avohq.io/4.0/i18n.md
- Which `avo.*` keys are reserved and which roots are yours to fill: https://docs.avohq.io/4.0/i18n.md#safe-keys
- Multi-language URLs guide (locale in the route, e.g. `/de/resources/users`): https://docs.avohq.io/4.0/guides/multi-language-urls.md
- Multilingual records guide (translating the *data*, not the chrome): https://docs.avohq.io/4.0/guides/multilingual-content.md

## When this applies

**Explicit (Avo named):** "set the Avo locale to `:de`", "add `self.translation_key` to this resource", "localize the `Product` resource / this action / this field", "translate Avo into Spanish", "generate the Avo locale files", "make the Avo admin RTL".

**Implicit (no mention of Avo/i18n):** "translate the admin to French / Spanish / German", "the admin needs to be in Arabic" or "support right-to-left", "localize the resource / field / action labels", "rename this field's label per language", "make the admin multilingual", "change the admin's language", "different label depending on the language", "the field help text should be translated", "customize the Save button wording for this one resource".

**Not this skill:** translating the *content of records* (a `title` column that differs per language) is the **multilingual records** guide, not i18n. Putting the locale in the URL (`/en/...`, `/de/...`) is the **multi-language URLs** guide. Point the user there and stop.

## Workflow

**Know the cascade before you edit anything.** Every label goes through the same four layers, first one with a value wins:

1. **The value at the call site** — `field :dates, name: "Period"`, `card Avo::Cards::UsersMetric, label: "Active users"`.
2. **The i18n key** — derived as described below, or pinned with `self.translation_key` / `translation_key:`.
3. **The class attribute** — `self.name`, `self.message`, `self.label`, `self.description` on actions, scopes, cards, dashboards.
4. **What Avo generates** — the humanized class name or field id, or Avo's own translated string (`avo.run`, `avo.save`, …).

Not every layer exists everywhere (resources have no naming attribute; actions take nothing at the call site) but the order never changes. The consequence that matters: **the locale file beats a class attribute**, which is what lets an app keep English defaults in code and translate over them without touching the class — but a call-site value beats the locale file, so a hardcoded `name:`/`label:` at the declaration is what to remove first when a translation "doesn't apply".

### 1. Get editable locale files

Avo's locale files live inside the gem and are not copied on install. To edit any Avo-provided string (or add a brand-new language), generate local copies first:

```bash
bin/rails generate avo:locales
```

That copies all bundled `avo.<locale>.yml` files into `config/locales/`. Edit the ones you need; add `config/locales/avo.<new_locale>.yml` for a language Avo doesn't ship, using a shipped file as the template. Rails auto-loads everything under `config/locales`, so no registration step.

For **custom** resource/action/field labels (the common case), you don't need the generator at all — just add your own keys under the `avo:` namespace in any locale file (e.g. `config/locales/avo.en.yml`), following the shapes below.

### 2. Localize a resource

Set `self.translation_key` on the resource, then supply the pluralized name under that key. This changes the resource's label **everywhere** in Avo (sidebar, breadcrumbs, headings):

```ruby
# app/avo/resources/user.rb
class Avo::Resources::User < Avo::BaseResource
  self.title = :name
  self.translation_key = "avo.resource_translations.user"
end
```

```yaml
# config/locales/avo.es.yml
es:
  avo:
    resource_translations:
      user:
        zero: "usuarios"
        one: "usuario"
        other: "usuarios"
```

Omit `self.translation_key` and Avo derives it from the class name, **namespace included** — `Avo::Resources::Galaxy::Planet` defaults to `avo.resource_translations.galaxy/planet`. So for a plain resource you often only need the YAML, no Ruby change.

### 3. Localize an action

Same convention. Avo looks under `avo.action_translations.<class_path>` for the `name`, `message`, `confirm_button_label`, `cancel_button_label`, and `description` sub-keys before falling back to the class attributes (`self.name`, `self.message`, …):

```ruby
# app/avo/actions/toggle_inactive.rb
class Avo::Actions::ToggleInactive < Avo::BaseAction
  # Optional — defaults to avo.action_translations.toggle_inactive
  # self.translation_key = "avo.action_translations.toggle_inactive"
end
```

```yaml
# config/locales/avo.sv.yml
sv:
  avo:
    action_translations:
      toggle_inactive:
        name: "Växla inaktiv"
        message: "Är du säker på att du vill växla inaktiv status?"
        confirm_button_label: "Växla"
        cancel_button_label: "Avbryt"
        description: "Växlar den inaktiva statusen för användaren"
      city/update:            # namespaced: Avo::Actions::City::Update
        name: "Uppdatera stad"
```

`self.name`/`self.message`/button labels (strings **or** lambdas) remain the fallback when no key is translated — keep them for dynamic labels that depend on `arguments`/`record`.

### 4. Localize fields

When a field has no explicit `translation_key:`, Avo resolves its label through a **cascade**, using the first key that has a translation:

1. `avo.resource_translations.<resource>.fields.<field_id>` — resource-scoped; overrides a label for **one** resource.
2. `avo.field_translations.<field_id>` — shared across every resource using that field id.
3. Humanized field id — the fallback.

Point a field at the shared key explicitly with `translation_key:` (this **bypasses the cascade** entirely):

```ruby
# app/avo/resources/project.rb
class Avo::Resources::Project < Avo::BaseResource
  def fields
    field :id, as: :id
    field :files, as: :files, translation_key: "avo.field_translations.file"
  end
end
```

```yaml
# config/locales/avo.es.yml
es:
  avo:
    field_translations:
      file:
        one: "archivo"
        other: "archivos"
    resource_translations:
      product:
        fields:
          title:                # wins over field_translations.title, only on Product
            one: "Título del producto"
            other: "Títulos del producto"
```

**`help`, `placeholder`, and `include_blank`** resolve from **sibling keys under the same translation key** — no need to pass them in Ruby. Set them once in YAML and drop the Ruby options:

```yaml
# config/locales/avo.sv.yml
sv:
  avo:
    field_translations:
      dates:
        one: "Datumintervall"
        other: "Datumintervall"
        help: "Valfritt. Standardperiod: 1 vecka tillbaka till idag."
        placeholder: "Välj datum"
        include_blank: "Ingen"
```

```ruby
field :dates, as: :date_time   # help/placeholder/include_blank come from the locale
```

Explicit `help:`/`placeholder:`/`include_blank:` (strings or lambdas) still win over the locale file.

### 5. Localize tabs and panels

Tab and panel titles resolve through the **resource's** translation key too. Avo parameterizes the configured `title:` (downcased, non-alphanumerics turned into `_`) and looks it up under a `tabs` or `panels` scope:

- `avo.resource_translations.<resource>.tabs.<title>` for a `tab`
- `avo.resource_translations.<resource>.panels.<title>` for a `panel`

So `tab title: "Activity"` resolves to `avo.resource_translations.user.tabs.activity`, and `panel title: "Contact information"` to `avo.resource_translations.user.panels.contact_information`:

```yaml
# config/locales/avo.es.yml
es:
  avo:
    resource_translations:
      user:
        tabs:
          activity: "Actividad"
        panels:
          contact_information: "Información de contacto"
```

The configured `title:` stays the fallback when the key has no translation. To pin a different key, pass `translation_key:` to the `tab` or `panel` and Avo uses it verbatim:

```ruby
tab title: "Activity", translation_key: "avo.resource_translations.user.tabs.recent_activity" do
  # ...
end
```

### 6. Localize button labels

`avo.save` covers every Save button globally. To override it for **one** resource, add a `save` key under that resource's translation key:

```yaml
# config/locales/avo.en.yml
en:
  avo:
    resource_translations:
      product:
        save: "Save the product!"
```

### 7. Localize scopes, cards, and dashboards

Three more roots follow the same convention, derived by the **add-on gems** that provide those entities — so they only exist in an app that has the gem installed:

| Entity | Key | Attributes | Derived by |
| --- | --- | --- | --- |
| Scope | `avo.scope_translations.<class_path>` | `name`, `description` | `avo-scopes` |
| Card | `avo.card_translations.<class_path>` | `label`, `description`, `discreet_description` | `avo-dashboards` |
| Dashboard | `avo.dashboard_translations.<class_path>` | `name`, `description` | `avo-dashboards` |

Namespaced classes use the same slash-joined path as resources (`avo.card_translations.sales/monthly`), `self.translation_key` overrides the derived path, and the class attribute stays the fallback. Detail: https://docs.avohq.io/4.0/i18n.md#localizing-scopes-cards-and-dashboards — and read the gem's own skill before writing the YAML, since each gem owns how its labels resolve.

Don't confuse these with the gems' **own** chrome (the refresh control, the count pill), which lives under `avo.scopes.*` and `avo.cards.*` — deliberately separate namespaces.

**A card's per-registration `label:` wins over its translation key.** Unlike actions, a card can be labelled where it's registered (`card Avo::Cards::UsersMetric, label: "Active users"`), and that override is more specific than a per-class key — otherwise a dashboard registering the same card class twice would collapse both to one string. If such an override also needs translating, pass a lambda.

### 8. Set or switch the interface language

`config.locale` sets Avo's locale for **Avo requests only** — the rest of the app keeps `config.i18n.default_locale`. Default is `nil` (falls back to the app default):

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.locale = :de   # default: nil
end
```

Two request params switch language on the fly:

- **`?set_locale=pt-BR`** — sets Avo's default locale process-wide **until the server restarts** (it mutates `Avo.configuration.locale`). Affects every user; use it as a switch, not per-user preference.
- **`?force_locale=pt-BR`** — sets the locale for that request only, but Avo **keeps the param in every link** while you navigate. Remove it to return to the configured locale. Good for previewing a translation without changing config.

### 9. Right-to-left languages

RTL is **automatic** — Avo detects it from the active locale and flips the layout (`dir="rtl"`, mirrored chrome) with no configuration. Built-in RTL locales: `ar`, `he`, `fa`, `ur`, `yi`, `ps`, `sd`, `ku`, `ckb`, `ug`, `dv`. Matching is on the **language segment**, so regional variants like `ar-EG` count as RTL too. To ship an Arabic admin, translate into `avo.ar.yml` and set the locale — the layout follows.

## What you can safely put under `avo.`

Avo's locale files, every add-on gem's, and the app's own deep-merge into **one `avo` tree per locale**, and `config/locales` loads **last**. Overriding Avo's strings is supported — it is most of what this skill does. What silently breaks an app is changing a key's **shape**:

- **Replace a string with a string; never nest beneath one.** A String and a Hash cannot merge, so the file that loads last replaces the other outright — no error, no warning, the label just stops rendering.
- **Strings that read like namespaces are the live hazard.** `avo.actions`, `avo.resources`, `avo.dashboards`, `avo.dashboard`, `avo.filters`, `avo.pages` and `avo.tools` are labels Avo renders, as are one-word keys like `avo.all`, `avo.copy`, `avo.confirm`, `avo.new`, `avo.edit`, `avo.delete`, `avo.reset`, `avo.run`, `avo.view`, `avo.save` and `avo.close`. Treat them as taken.
- **Avo keeps eight namespaces of its own**: `avo.appearance`, `avo.checkbox_list`, `avo.global_search`, `avo.key_value_field`, `avo.media_library`, `avo.nested`, `avo.order` and `avo.search`. They nest a level or two deeper, and the rule holds at every level — override a string, never nest beneath one.
- **Pluralization hashes are the exception.** A sibling beside `one:`/`other:` under `avo.file`, `avo.record`, `avo.number_of_items` or `avo.x_items_more` is safe — pluralization reads only the plural keys and ignores everything else. Nested ones exist too (`avo.checkbox_list.hidden_selections`); tell one apart by its **keys** (plural categories), not its depth. That is exactly why `avo.resource_translations.<r>` is legitimately both a plural leaf **and** a subtree root carrying `.fields`/`.tabs`/`.panels`/`.save`.
- **Pagy's pagination strings are out of scope.** They live in `locales/pagy/` and load through Pagy's own loader, outside the `avo.*` tree — none of this applies to them.
- **Six derived roots are yours to fill.** `resource_translations`, `action_translations`, `field_translations` (core), `scope_translations` (`avo-scopes`), `card_translations` and `dashboard_translations` (`avo-dashboards`). Avo ships nothing under them.
- **`avo.filter_translations` is not a root** — no code derives it. Filters have no derived translation root today; localize one by calling `I18n.t` from its `self.name` block with a key of your own choosing.

List what is currently taken, **without** mutating the app:

```bash
bin/rails runner 'puts I18n.t("avo").select { |_, v| v.is_a?(String) }.keys.sort'
```

Don't reach for `bin/rails generate avo:locales` just to look — it copies Avo's locale files into `config/locales`, pinning today's wording into the app. Run it only when editable copies are actually wanted. Full rule and the worked collision: https://docs.avohq.io/4.0/i18n.md#safe-keys

### Add-on gem locales

The locale generator covers Avo core. Each add-on keeps its strings under its own namespace inside `avo.*`, and **most ship English only** — every other language is the app's to supply, in a file per gem or one file carrying all of them (they deep-merge into the same tree).

| Gem | Namespace |
| --- | --- |
| Advanced Search | `avo.global_search.*` |
| Collaboration | `avo.collaboration.*` |
| Dashboards & Cards | `avo.cards.*` |
| Dynamic Filters | `avo.dynamic_filters.*` |
| Forms & Pages | `avo.forms.*` |
| Intelligence | `avo.intelligence.*` |
| REST API | `avo.api.token.*` |
| Scopes | `avo.scopes.*` |

Two of them need no locale file from the app:

- **Advanced Search** renders only `avo.global_search.*` keys and `avo.all`, and core translates all of them in each bundled locale. Four — `avo.global_search.direct_match`, `.search_results`, `.searching_on` and `avo.all` — only reached core's locale files **after 4.1.6**; on `4.1.6` and earlier they fall back to English, so define them in the app's own locale file until it's on a newer Avo.
- **REST API** ships its own `avo.api.token.*` tree translated in every locale core supports, so the API-tokens screen follows the panel's language with no work from you. Override any of those strings by defining the same key in the app — you only write the keys you're changing. Its relative-time chips come from Rails' `datetime.distance_in_words`, which Rails ships in English only: add [rails-i18n](https://github.com/svenfuchs/rails-i18n) for translated relative times, or the chips show the exact timestamp instead.

## Key options

| Hook | Where | Does |
| --- | --- | --- |
| `self.translation_key` | Resource class | Maps the resource to `avo.resource_translations.<...>`; changes its label everywhere. Defaults from class name (namespace included). |
| `self.translation_key` | Action class | Maps the action to `avo.action_translations.<...>` (`name`/`message`/`confirm_button_label`/`cancel_button_label`/`description` sub-keys). |
| `translation_key:` | Field declaration | Pins the field to one key and **skips the cascade**. Omit to use resource-scoped → shared → humanized. |
| `avo.resource_translations.<r>.fields.<f>` | YAML | Resource-scoped field label — overrides the shared one for a single resource. |
| `avo.field_translations.<f>` | YAML | Shared field label + `help`/`placeholder`/`include_blank` siblings across all resources. |
| `avo.resource_translations.<r>.tabs.<t>` | YAML | Tab title, keyed on the parameterized `title:`. Pin a different key with `translation_key:` on the `tab`. |
| `avo.resource_translations.<r>.panels.<p>` | YAML | Panel title, same convention as tabs; `translation_key:` on the `panel` overrides it. |
| `avo.resource_translations.<r>.save` | YAML | Per-resource Save-button text (else global `avo.save`). |
| `avo.scope_translations.<s>` | YAML | Scope `name`/`description`. Root derived by `avo-scopes`. |
| `avo.card_translations.<c>` | YAML | Card `label`/`description`/`discreet_description`. Root derived by `avo-dashboards`. |
| `avo.dashboard_translations.<d>` | YAML | Dashboard `name`/`description`. Root derived by `avo-dashboards`. |
| `config.locale` | Initializer | Avo's interface language for Avo requests only. Default `nil` → app default. |
| `?set_locale=` param | URL | Switches Avo's default locale process-wide until restart. |
| `?force_locale=` param | URL | Switches locale for the current navigation only; sticks in links until removed. |
| `bin/rails g avo:locales` | Shell | Copies the 19 bundled locale files into `config/locales` for editing. |

## Gotchas

- **Locale files ship inside the gem — not copied on install.** To edit Avo's own strings or add a language, run `bin/rails g avo:locales` first. For custom labels you only need your own keys under `avo:`; the generator is optional.
- **Explicit `translation_key:` on a field bypasses the cascade.** You lose the resource-scoped → shared → humanized fallback and the automatic `help`/`placeholder`/`include_blank` sibling lookup. Only pin a key when you want exactly that key.
- **Default keys include the namespace.** `Avo::Resources::Galaxy::Planet` → `avo.resource_translations.galaxy/planet`; `Avo::Actions::City::Update` → `avo.action_translations.city/update` (underscored, slash-joined). Match that path in YAML or the lookup misses and you fall back to the humanized name.
- **Pluralization keys are required to get a translated name.** Resource/field name lookups run `I18n.t(key, count:, default:)`, so provide `one`/`other` (and `zero` where relevant). A subtree holding no plural key at all raises `I18n::InvalidPluralizationData` — passing `default:` does **not** prevent it — but Avo rescues that and falls back to the humanized name. So a resource key holding only `save:` works fine; you just don't get a translated resource name out of it. Keep `one:`/`other:` beside the nested keys when you want both. Code of your own reading these keys with a `count:` has to add the plural keys or rescue the exception itself.
- **Nesting under a path Avo holds as a string destroys that string.** The tree deep-merges per locale and the app's `config/locales` loads last, so `avo.dashboards.my_dashboard.name` turns the sidebar's "Dashboards" heading into a Hash and it stops rendering — silently. Use the derived root instead (`avo.dashboard_translations.my_dashboard.name`), and check `I18n.t("avo")` for strings before inventing a namespace.
- **`set_locale` is global and sticky.** It mutates `Avo.configuration.locale` and persists until the server restarts, affecting all users — it is not a per-user preference. Use `force_locale` for a scoped, reversible switch (it rides along in every link until removed).
- **RTL is automatic and matches on the language segment.** `ar`, `he`, `fa`, `ur`, `yi`, `ps`, `sd`, `ku`, `ckb`, `ug`, `dv` — and regional variants (`ar-EG`) — flip the layout with no config. Don't hand-roll a direction toggle.
- **Don't confuse chrome with data.** This skill localizes labels/buttons/help (the admin UI). Translating record *content* is the multilingual-records guide; putting the locale in the URL is the multi-language-URLs guide.
- **Verify before writing.** Key names and the cascade drift between versions — check the docs URL above or the app's installed Avo source rather than trusting memory.

## Report

When done, tell the user:

- Which locale file(s) you created or edited (full paths) and any resource/action/field file(s) where you set `translation_key`, plus any generator command run (`bin/rails g avo:locales`).
- The translation keys you added and the resource/action/field/scope/card/dashboard each targets — call out where you relied on the field cascade vs. an explicit `translation_key:`.
- The active-locale change, if any (`config.locale`, or that they can preview with `?force_locale=`), and whether RTL will engage for the chosen language.
- Anything still needed: add the remaining `one`/`other` plural forms, translate the other bundled strings, restart the server after a `config.locale` change, or move to the multilingual-records / multi-language-URLs guide if the real goal was record content or locale-in-URL.
