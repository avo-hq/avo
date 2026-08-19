---
name: avo-fields
description: Add or change fields in an Avo resource's `def fields` — pick the `as:` type, set options (required, default, help, visibility, formatting), and use computed and view-specific fields. Use when the user wants to add a field to an Avo resource, or — said without naming Avo — "add a status field to the Project model", "make the email field required", "show the user's avatar", "add a dropdown for order status", "the price should display as currency", "add a rich-text editor for the body", "the markdown editor is too short / make it taller", "show the whole body on the show page instead of the More content preview", "hide the notes field on the index page", "add a star rating", "make the name column sortable", "show a badge for the order state", or "add a color picker / date picker / progress bar to a model". For belongs_to / has_many / has_one and other association fields, use the avo-associations skill instead.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community; some field types need companion gems (see Gotchas)
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Add or change an Avo field

In Avo (a Rails admin framework), the columns shown on a resource's Index, Show, New, and Edit pages are declared as **fields** inside the `def fields` method of `app/avo/resources/<model>.rb`. Almost every "add/change/hide a field on the X model" request lands in that one method.

A field looks like:

```ruby
field :column_name, as: :field_type, **options
```

- `:column_name` — a database column **or** any method/attribute on the model.
- `as: :field_type` — how it renders (`:text`, `:select`, `:boolean`, `:money`, …). Omit `as:` and it defaults to `:text`.
- `**options` — label, visibility, formatting, validation cues, etc. (see [Key options](#key-options)).

**Docs** (fetch on demand — do not rely on memory for exact option names):
- Docs map / index: https://docs.avohq.io/4.0/docs-map.md
- Declaring fields & view-specific methods: https://docs.avohq.io/4.0/fields.md
- Common options (guide + full API): https://docs.avohq.io/4.0/field-options.md · https://docs.avohq.io/4.0/field-options-api.md
- The ~38-type catalog (one page per type, with type-specific options): https://docs.avohq.io/4.0/fields/text.md — swap `text` for any type below. Fetch the specific type's page before using its niche options.
- Layout DSL inside `def fields` (panels, tabs, sidebar, cards, columns): https://docs.avohq.io/4.0/fields-layout.md
- Field discovery (auto-map columns/associations): https://docs.avohq.io/4.0/field-discovery.md
- HTML attributes on a field: https://docs.avohq.io/4.0/html.md

## When this applies

Use this skill for anything **inside `def fields`** except associations:

- Adding, removing, renaming, or reordering a field.
- Changing a field's type (e.g. plain text → a `select` dropdown or a `badge`).
- Setting options: required, default, help text, placeholder, disabled/readonly, sortable, visibility per view, formatting, copyable, etc.
- Computed (block) fields that derive a value not stored in a column.
- Arranging fields with the layout DSL (`panel`, `card`, `sidebar`, `tabs`/`tab`, `header`, column `width`).
- Auto-generating fields with `discover_columns` / `discover_associations`.

**Not this skill:**
- `belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many` and other relationship fields → **avo-associations** skill.
- Authoring a brand-new *custom field type* (a reusable component you invent) → **avo-custom-fields** skill. Note `rails g avo:field NAME` scaffolds a new custom type; it is **not** how you add a normal field — for that you just edit `def fields`.

## Workflow

1. **Find the resource file.** It's `app/avo/resources/<model>.rb` (singular, snake_case — e.g. the `Project` model → `app/avo/resources/project.rb`). If unsure, `Glob` `app/avo/resources/*.rb` or `Grep` for the model name. Read the file and locate `def fields` (or the view-specific methods below).

2. **Confirm the backing attribute.** The first argument should match a real DB column or a model method. Check `db/schema.rb` (or the model) so you use the right column name and can pick a type that fits its data type. If the value isn't stored anywhere, it must be a [computed block field](#computed-block-fields).

3. **Pick the field type** using the [decision table](#choosing-a-field-type). When in doubt, fetch that type's docs page.

4. **Check for a gem gate.** A few types need a companion gem or ENV var and will error without it — see [Gotchas](#gotchas). If the user asks for one of those, tell them the gem to add.

5. **Place the field** in the intended view(s). By default a field shows on all four views; use `def fields` for all views, or a view-specific method (below) when a view needs a different set. Respect existing ordering and formatting in the file.

6. **Add options** — start minimal (`as:` + label if needed), then layer on only what the request asks for.

7. **Report** what changed (see [Report](#report)). Don't run the app; if you want to sanity-check syntax, a `ruby -c` on the file is enough.

### Which method to edit

`def fields` is the catch-all used for every view when no more specific method exists. Override per view or per view-group only when a view genuinely needs a different set:

| Method            | Applies to                        |
| ----------------- | --------------------------------- |
| `def fields`      | any view with no specific method  |
| `def index_fields`| Index                             |
| `def show_fields` | Show                              |
| `def edit_fields` | Edit **and** Update               |
| `def new_fields`  | New **and** Create                |
| `def display_fields` | Index **and** Show             |
| `def form_fields` | New, Create, Edit **and** Update  |

Specific view methods beat view-group methods, which beat `fields`. Prefer a single `def fields` + per-field `hide_on:`/`only_on:` for small differences; reach for separate methods only when the field lists really diverge.

## Choosing a field type

Map the need to an `as:` type. All built-in types are **Community (free)**; the ⚠️ ones need a companion gem (see [Gotchas](#gotchas)).

| The user wants…                                        | Use                          | Example |
| ------------------------------------------------------ | ---------------------------- | ------- |
| A short single-line string                             | `:text`                      | `field :title, as: :text` |
| A long / multi-line string                             | `:textarea`                  | `field :body, as: :textarea` |
| A number                                               | `:number`                    | `field :age, as: :number` |
| A masked password input                                | `:password`                  | `field :password, as: :password` |
| A yes/no checkbox                                      | `:boolean`                   | `field :active, as: :boolean` |
| A hash of on/off toggles                               | `:boolean_group`             | `field :roles, as: :boolean_group, options: {admin: "Admin", editor: "Editor"}` |
| A dropdown of fixed choices                            | `:select`                    | `field :type, as: :select, options: {Draft: :draft, Live: :live}` |
| Multiple choices from a fixed set                      | `:select` (`multiple: true`) or `:checkbox_list` | `field :tags, as: :select, multiple: true, options: {...}` |
| Radio buttons                                          | `:radio`                     | `field :plan, as: :radio, options: {...}` |
| A country picker                                       | `:country`                   | `field :country, as: :country` |
| A date                                                 | `:date`                      | `field :birthday, as: :date` |
| A date **and** time                                    | `:date_time`                 | `field :published_at, as: :date_time` |
| A time only                                            | `:time`                      | `field :opens_at, as: :time` |
| A colored status pill (map value → color)              | `:badge`                     | `field :status, as: :badge, options: {success: "done", warning: "pending"}` |
| A live status dot (loading/failed/success/neutral)     | `:status`                    | `field :state, as: :status, success_when: [:done], loading_when: [:running], failed_when: [:failed]` |
| A tag input / list                                     | `:tags`                      | `field :skills, as: :tags` |
| A star rating                                          | `:stars`                     | `field :rating, as: :stars` |
| A progress bar (slider on forms)                       | `:progress_bar`              | `field :progress, as: :progress_bar` |
| Editable flat JSON key/value pairs                     | `:key_value`                 | `field :meta, as: :key_value` |
| Structured array data                                  | `:array`                     | `field :items, as: :array` |
| A code editor (syntax-highlighted)                     | `:code`                      | `field :snippet, as: :code, language: "javascript"` |
| The record id                                          | `:id`                        | `field :id, as: :id` |
| A hidden form value                                    | `:hidden`                    | `field :token, as: :hidden` |
| A section title between fields                         | `:heading`                   | `field :section, as: :heading` (layout, not a DB column) |
| A hover preview icon on the Index row                  | `:preview`                   | `field :preview, as: :preview` |
| A currency amount ⚠️                                    | `:money`                     | `field :price, as: :money, currencies: %w[USD EUR]` |
| A rich-text WYSIWYG editor ⚠️ (recommended)            | `:rhino`                     | `field :body, as: :rhino` |
| Basecamp's Lexxy editor (Action Text) ⚠️                | `:lexxy`                     | `field :body, as: :lexxy` |
| A GitHub-style Markdown editor ⚠️                       | `:markdown`                  | `field :body, as: :markdown` |
| A simpler Markdown editor ⚠️                            | `:easy_mde`                  | `field :notes, as: :easy_mde` |
| The Trix editor (ActionText)                           | `:trix`                      | `field :body, as: :trix` |
| A single file upload (ActiveStorage)                   | `:file`                      | `field :cv, as: :file` |
| Multiple file uploads                                  | `:files`                     | `field :docs, as: :files` |
| An uploaded avatar image                               | `:avatar`                    | `field :photo, as: :avatar` |
| A Gravatar from an email column                        | `:gravatar`                  | `field :email, as: :gravatar` |
| An image from a stored URL                             | `:external_image`            | `field :logo, as: :external_image` |
| A point on a map ⚠️                                      | `:location`                  | `field :coordinates, as: :location` |
| A geographic area on a map ⚠️                            | `:area`                      | `field :zone, as: :area` |

For anything relationship-shaped ("show the user's posts", "attach an author") use the **avo-associations** skill.

### The editor fields behave alike

`trix`, `rhino`, `lexxy`, `markdown`, `easy_mde`, `tip_tap` and `code` render different editors on forms but share one Show and form behavior, so switching between them doesn't change how records read:

- **On Show** the value is clipped to a short, faded preview with a `More content` link that expands it and a `Less content` link that collapses it back. Pass `always_show: true` to render the full value instead. `code` and `easy_mde` joined this in Avo **4.1.10** — before that they rendered in full.
- **On forms** the editor sits in a viewport that opens 20rem tall, scrolls its overflow, and can be dragged taller or shorter by its bottom-end handle. The height is remembered in the browser's local storage per mount path, resource/action and field. Change the two heights globally by defining `--avo-resizable-editor-default-height` and `--avo-resizable-editor-min-height` on `:root` in a stylesheet registered with Avo's asset manager — there is no per-field option.
- Since **4.1.10** the `code` field's `height:` option applies on Show only; on forms the resizable viewport wins.

Which one to reach for: `rhino` for HTML rich text (or `lexxy` on Rails >= 8.0.2), `trix` for a zero-dependency default, `markdown` (Marksmith) for markdown, `code` for source. `tip_tap` is deprecated in favor of `rhino`.

## Key options

Every field accepts these common options (full list + types at the field-options-api page). Pass a literal value or, unless noted, a lambda.

- **`name`** — override the label (default is the humanized id). `field :is_available, as: :boolean, name: "Availability"`. For localized apps, translate via i18n instead of hardcoding.
- **Visibility** — `hide_on:`, `show_on:`, `only_on:`, `except_on:` take `:index`, `:show`, `:new`, `:edit`, `:preview` plus shorthands `:forms` (new+edit), `:display` (index+show), and `:all` (only for `hide_on`/`show_on`). Example: `field :notes, as: :textarea, hide_on: [:index, :show]`.
- **`visible:`** — a lambda for conditional display. It can see `context` and `resource`; the record is `resource.record`. On create the record is `nil`, so **use safe navigation**: `visible: -> { resource.record&.published? }`.
- **`required:`** — adds an asterisk (cosmetic only; Avo adds it automatically when the model has a presence validator). Real enforcement is model validation.
- **`disabled:`** vs **`readonly:`** — both render the input disabled on forms. `disabled:` **also ignores the value on save** (safe against DOM tampering). `readonly:` is UI-only — a user can re-enable it and submit; don't rely on it for protection.
- **`default:`** — pre-fills the New form (and action modals): `default: -> { Time.current }`.
- **`help:`** / **`label_help:`** — help text (HTML allowed) below the input (forms only) or below the label (every view).
- **`placeholder:`** — placeholder for empty text-like inputs.
- **`sortable:`** — makes the Index column sortable. `true` for real columns; a `-> { query.order(...) }` lambda (receives `query` and `direction`) for computed fields.
- **Number `format:`** — formats `:number` fields on Index and Show with `:delimited`, `:percentage`, or `:human`; forms keep the raw number. A formatted number is end-aligned in tables, while a bare number stays start-aligned for identifier/year-shaped values. Rails i18n controls delimiters and separators. For money use the `:money` field, and for anything else `format_display_using:`.
- **`format_using:`** — reshape the displayed value. **Runs on form views too**, so branch on the view when the form should stay editable: `format_using: -> { view.form? ? value : value.upcase }`. View-scoped variants exist (`format_display_using`, `format_index_using`, `format_show_using`, `format_form_using`, …) — the most specific one wins, they don't chain.
- **`update_using:`** — parse the raw form `value` before it's saved.
- **`nullable:`** / **`null_values:`** — store empty input as `NULL` (optionally define which values count as null).
- **`copyable:`** — clipboard icon on Show/Index. Copies the **displayed** (formatted) value.
- **`always_show:`** — editor fields only (`trix`, `rhino`, `lexxy`, `markdown`, `easy_mde`, `tip_tap`, `code`). `true` renders the full value on Show instead of the collapsed preview. Defaults to `false`.
- **`link_to_record:`** — make the Index cell a link to the record. Only on `:id`, `:text`, `:gravatar`, and `belongs_to`.
- **`for_attribute:`** — back the field with a different attribute than its id (lets you show one column two ways).
- **`width:`** / **`stacked:`** — column width (`25/33/50/66/75/100`; any value <100 auto-stacks) and label-above-value layout. `stacked:` on the field wins everywhere, so `stacked: false` opts out of the auto-stacking and of sidebars/preview stacking too.
- **`html:`** — attach `style`/`classes`/`data` to the field's wrapper/label/input per view (e.g. allow wrapping on Index: `html: {index: {wrapper: {classes: "whitespace-normal"}}}`). See the html page.

### Computed (block) fields

When the value isn't a stored column, pass a block. Inside it you have `record`, `resource`, and `view`:

```ruby
field "Full name", as: :text do
  "#{record.first_name} #{record.last_name}"
end

field "Has posts", as: :boolean do
  record.posts.any?
end
```

Block fields render **only on Index and Show** (they have no input) and **can't use `sortable: true`** (pass a sort lambda instead). Give them an explicit label string as the first argument.

### Layout inside `def fields`

The same method arranges fields. Use `panel`/`card` to group, `sidebar` (inside a panel) for compact fields, `tabs`/`tab` for tabbed sections, `header` to reposition the page chrome, and per-field `width:` for multi-column rows. This overlaps page-level layout — see the fields-layout docs page before building complex structures.

```ruby
def fields
  field :id, as: :id
  panel title: "Details" do
    field :first_name, as: :text, width: 50
    field :last_name,  as: :text, width: 50
    sidebar do
      field :active, as: :boolean, only_on: :show
    end
  end
end
```

### Field discovery

To auto-generate fields from the model instead of listing them, call `discover_columns` (columns, rich text, tags) and `discover_associations` (attachments, relationships). Scope with `only:`/`except:`, and pass any other keyword to forward it to every discovered field:

```ruby
def fields
  discover_columns only: [:title, :body, :published_at]
  discover_associations except: [:audit_logs]
end
```

## Gotchas

- **Gem-gated types break without their companion gem** (the field silently fails to render or raises). If the user asks for one, tell them to add the gem:
  - `:rhino` → `gem "avo-rhino_field"`
  - `:lexxy` → `gem "avo-lexxy_field"` (Basecamp's Lexxy editor for Action Text; needs Rails >= 8.0.2)
  - `:markdown` → `gem "marksmith"` + `gem "commonmarker"`
  - `:money` → `gem "avo-money_field"` + `gem "money-rails", "~> 1.12"` (and `monetize :price_cents` on the model)
  - `:location` / `:area` → `gem "mapkick-rb"` (**not** `mapkick`) + `MAPBOX_ACCESS_TOKEN` env var
  - Reactive fields (`react_on:`) → `gem "avo-reactive_fields"`
  - Some of these gems live on the `packager.dev` source — point the user to the Avo 4 upgrade guide's gems section.
- **`tip_tap` is deprecated** — use `:rhino` for a WYSIWYG editor.
- **`always_show` on `markdown` needs `marksmith` >= 0.6.0.** The collapsed preview is rendered by the Marksmith editor itself; on older versions the field always shows its full content and the option has nothing to do.
- **`markdown` was renamed.** The old `markdown` field is now `easy_mde`; the new `markdown` is the Marksmith editor. Don't confuse them.
- **`required:` and `readonly:` are cosmetic.** Enforce with model validations (`validates :x, presence: true`) and use `disabled:` when you need the value ignored on save.
- **`format_using:` runs on form views too** — return the raw `value` when `view.form?` so the input stays editable, or use a `format_display_using:`/`format_*_using:` variant.
- **Number `format:` is display-only** — prefer `field :population, as: :number, format: :delimited` to a custom delimiter proc; a supplied `format_display_using:` or view-specific formatter still wins.
- **Computed block fields** show only on Index/Show and can't be `sortable: true`.
- **`visible:` lambdas see `resource.record == nil` on create** — always safe-navigate (`resource.record&.foo`).
- **`select` takes exactly one of `options:`, `grouped_options:`, or `enum:`** — never combine them.
- **Fields an external tool submits must still be declared** on the form views. If a resource tool renders the input, keep the field with `hide_on: :forms` so Avo can parse and save the value.
- **`badge` vs `status`:** `badge` maps arbitrary values to colored pills (`options:`); `status` is a live indicator with `success_when:`/`loading_when:`/`failed_when:` arrays (everything else → neutral).

## Report

After editing, tell the user:

- The file and method you changed (`app/avo/resources/<model>.rb` → `def fields`).
- Each field added/changed: column, `as:` type, and any notable options.
- Any gem or ENV var they must add for a gated type, and any model change needed (validation for `required`, `monetize` for money, an enum for an enum-backed select).
- Which views the field now appears on, if you set visibility.
