---
name: avo-i18n
description: Translate and localize the Avo admin — resource, action, and field labels, tab and panel titles, field help/placeholder/include_blank text, save-button labels, the interface language, and right-to-left layout — via `config/locales/avo.<locale>.yml`, `self.translation_key`, and `config.locale`. Use when the user wants to translate the admin to another language (French/Spanish/German/Arabic/…), localize or rename resource/field/action labels, translate tab or panel titles, make the admin multilingual, support RTL languages, change or force the admin's interface language, or show a different label per language.
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
- Multi-language URLs guide (locale in the route, e.g. `/de/resources/users`): https://docs.avohq.io/4.0/guides/multi-language-urls.md
- Multilingual records guide (translating the *data*, not the chrome): https://docs.avohq.io/4.0/guides/multilingual-content.md

## When this applies

**Explicit (Avo named):** "set the Avo locale to `:de`", "add `self.translation_key` to this resource", "localize the `Product` resource / this action / this field", "translate Avo into Spanish", "generate the Avo locale files", "make the Avo admin RTL".

**Implicit (no mention of Avo/i18n):** "translate the admin to French / Spanish / German", "the admin needs to be in Arabic" or "support right-to-left", "localize the resource / field / action labels", "rename this field's label per language", "make the admin multilingual", "change the admin's language", "different label depending on the language", "the field help text should be translated", "customize the Save button wording for this one resource".

**Not this skill:** translating the *content of records* (a `title` column that differs per language) is the **multilingual records** guide, not i18n. Putting the locale in the URL (`/en/...`, `/de/...`) is the **multi-language URLs** guide. Point the user there and stop.

## Workflow

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

### 7. Set or switch the interface language

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

### 8. Right-to-left languages

RTL is **automatic** — Avo detects it from the active locale and flips the layout (`dir="rtl"`, mirrored chrome) with no configuration. Built-in RTL locales: `ar`, `he`, `fa`, `ur`, `yi`, `ps`, `sd`, `ku`, `ckb`, `ug`, `dv`. Matching is on the **language segment**, so regional variants like `ar-EG` count as RTL too. To ship an Arabic admin, translate into `avo.ar.yml` and set the locale — the layout follows.

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
| `config.locale` | Initializer | Avo's interface language for Avo requests only. Default `nil` → app default. |
| `?set_locale=` param | URL | Switches Avo's default locale process-wide until restart. |
| `?force_locale=` param | URL | Switches locale for the current navigation only; sticks in links until removed. |
| `bin/rails g avo:locales` | Shell | Copies the 19 bundled locale files into `config/locales` for editing. |

## Gotchas

- **Locale files ship inside the gem — not copied on install.** To edit Avo's own strings or add a language, run `bin/rails g avo:locales` first. For custom labels you only need your own keys under `avo:`; the generator is optional.
- **Explicit `translation_key:` on a field bypasses the cascade.** You lose the resource-scoped → shared → humanized fallback and the automatic `help`/`placeholder`/`include_blank` sibling lookup. Only pin a key when you want exactly that key.
- **Default keys include the namespace.** `Avo::Resources::Galaxy::Planet` → `avo.resource_translations.galaxy/planet`; `Avo::Actions::City::Update` → `avo.action_translations.city/update` (underscored, slash-joined). Match that path in YAML or the lookup misses and you fall back to the humanized name.
- **Pluralization keys are required.** Resource/field name lookups run `I18n.t(key, count:, default:)`, so provide `one`/`other` (and `zero` where relevant). A bare string can raise `I18n::InvalidPluralizationData` or silently fall back to the computed name.
- **`set_locale` is global and sticky.** It mutates `Avo.configuration.locale` and persists until the server restarts, affecting all users — it is not a per-user preference. Use `force_locale` for a scoped, reversible switch (it rides along in every link until removed).
- **RTL is automatic and matches on the language segment.** `ar`, `he`, `fa`, `ur`, `yi`, `ps`, `sd`, `ku`, `ckb`, `ug`, `dv` — and regional variants (`ar-EG`) — flip the layout with no config. Don't hand-roll a direction toggle.
- **Don't confuse chrome with data.** This skill localizes labels/buttons/help (the admin UI). Translating record *content* is the multilingual-records guide; putting the locale in the URL is the multi-language-URLs guide.
- **Verify before writing.** Key names and the cascade drift between versions — check the docs URL above or the app's installed Avo source rather than trusting memory.

## Report

When done, tell the user:

- Which locale file(s) you created or edited (full paths) and any resource/action/field file(s) where you set `translation_key`, plus any generator command run (`bin/rails g avo:locales`).
- The translation keys you added and the resource/action/field each targets — call out where you relied on the field cascade vs. an explicit `translation_key:`.
- The active-locale change, if any (`config.locale`, or that they can preview with `?force_locale=`), and whether RTL will engage for the chosen language.
- Anything still needed: add the remaining `one`/`other` plural forms, translate the other bundled strings, restart the server after a `config.locale` change, or move to the multilingual-records / multi-language-URLs guide if the real goal was record content or locale-in-URL.
