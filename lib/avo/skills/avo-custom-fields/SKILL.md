---
name: avo-custom-fields
description: >-
  Author a brand-new reusable Avo field TYPE with `rails generate avo:field` when the ~38 built-in
  types don't fit — scaffolds Edit/Show/Index ViewComponents plus a `Field` config class, adds
  field-specific options, and customizes how the field renders. Use when the user wants to build a
  new field type for the admin — "add a new field type to Avo", "Avo doesn't have a field for X,
  build one", "I need a color-picker / slider / rating / custom-widget field", "render this
  attribute as a custom control on the form", "make a field that renders a custom widget", or
  "duplicate the text field and extend it". NOT for using an existing type (`field :x, as: :select`)
  or adding a normal field to a resource — that is the avo-fields skill.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Author a custom Avo field type

Avo (a Rails admin framework) ships ~38 built-in field types. When none of them fit, you can **author your own reusable field type** and then use it like any built-in: `field :progress, as: :progress_bar`. This skill is about *creating that type* with `bin/rails generate avo:field`, which scaffolds three [ViewComponents](https://viewcomponent.org/) — `Edit` (also used for `New`), `Show`, and `Index` — plus a `Field` configuration class. You edit those four files to define options and rendering.

**Critical distinction — do not confuse these two things:**

- **Using a field** — `field :status, as: :select`, adding/removing/reordering a field, changing an existing field's type or options → that's editing `def fields` in a resource. Use the **avo-fields** skill, not this one. "Add a status field to the Project model" is avo-fields.
- **Authoring a field type** — inventing a new `as:` value backed by your own components (a color picker, a slider, a star widget Avo doesn't have) → **this skill**. The tell is that the user wants behavior/rendering no built-in type provides, or explicitly says "new field type", "build a field", "custom widget field", or "extend the text field".

If the request is really "just show attribute X as a picker" and a built-in type already does it (`:select`, `:radio`, `:stars`, `:code`, `:key_value`, …), stop and hand off to **avo-fields** — authoring a whole type is overkill.

Custom fields are **Community (free)**.

**Docs** (fetch on demand — don't rely on memory for exact helper/option names):
- Docs map / index: https://docs.avohq.io/4.0/docs-map.md
- Custom fields (primary guide — generator, options, component helpers, Stimulus, non-model fields): https://docs.avohq.io/4.0/custom-fields.md
- Field wrappers (`field_wrapper` / `index_field_wrapper`, `dash_if_blank`, what the wrapper draws for you): https://docs.avohq.io/4.0/field-wrappers.md
- Eject an existing field's components (`--field-components`, `--view`, `--scope`) — tweak a built-in field's rendering without authoring a new type: https://docs.avohq.io/4.0/eject-views.md
- Custom CSS/JS pipeline (custom fields get NO automatic asset loading): https://docs.avohq.io/4.0/asset-handling.md
- Ship a field type from a gem (`register_field`, for plugin authors): https://docs.avohq.io/4.0/plugins.md
- Field visibility helpers (`hide_on`, `only_on`, …): https://docs.avohq.io/4.0/field-options.md

## When this applies

Use this skill when the user wants a field type that doesn't exist yet:

- "Add a new field type", "build a custom field", "Avo has no field for X".
- A specific custom widget: color picker, slider/range, dial, signature pad, rating other than `:stars`, a masked/formatted input, a bespoke display cell.
- "Duplicate/clone the text (or any) field and extend it" — start from a template with `--field-template`.
- Rendering a value as a custom control on the form, or a custom cell on Index/Show, with its own ERB/JS/CSS.
- A field whose value **isn't** a real column and needs custom getter/setter behavior on the model.

**Not this skill:**
- Adding or changing a normal field, picking an `as:` type, setting field options → **avo-fields**.
- Only restyling a built-in field's existing markup, everywhere or in one place → eject its components with `avo:eject --field-components` (see the eject-views doc) rather than authoring a new type.
- Loading the JS/CSS your new field needs → the pipeline setup lives in **avo-custom-ui** (asset-handling). This skill writes the field; that one wires the assets.

## Workflow

1. **Confirm it's really a new type.** Re-read the "Critical distinction" above. If a built-in type covers it, hand off to **avo-fields**.

2. **Generate the field.** Pick a snake_case name (the `as:` value users will type):

   ```bash
   bin/rails generate avo:field progress_bar
   ```

   This creates:
   - `app/avo/fields/progress_bar_field.rb` — the `Avo::Fields::ProgressBarField` config class (registers the type, holds options).
   - `app/components/avo/fields/progress_bar_field/{edit,show,index}_component.rb` + matching `.html.erb` — the three ViewComponents.

   To start from an existing built-in instead of blank text components, clone it (all components come out identical to the original, renamed):

   ```bash
   bin/rails generate avo:field super_text --field-template text
   ```

   The generator flag is `--field-template` (Avo's docs also write it `--field_template`; Thor accepts either). The `avo:field` generator has **no** `--view` or `--scope` option — those belong to `avo:eject --field-components` (used to override an *existing* field's components, not to author a new one).

3. **Restart the Rails server.** A new field type isn't picked up until you restart. Tell the user this explicitly — it's the #1 "my field doesn't work" cause.

4. **Define field-specific options** in `app/avo/fields/<name>_field.rb` — an `attr_reader` per option plus reading it in `initialize` (see [Key pieces](#key-pieces)). Options users pass to `field :x, as: :your_field, foo: 1` arrive in `args`.

5. **Customize the three components.** Edit the `.html.erb` templates to render your control on Edit and your display on Show/Index. Keep the `field_wrapper` / `index_field_wrapper` block so the field looks native (see [Key pieces](#key-pieces)).

6. **Wire assets if needed.** Custom fields have **no** automatic asset loading. Any JS/CSS must go through your own Avo asset pipeline — cross-link **avo-custom-ui**. Avo does ship a few reusable Stimulus controllers (e.g. `hidden-input`) you can attach without new assets.

7. **Handle non-model values.** If the field's `id` isn't a real column, add a getter and setter on the model (see [Gotchas](#gotchas)).

8. **Report** — see [Report](#report). If you want a quick syntax check, `ruby -c` the field file; don't boot the app.

## Key pieces

### The `Field` config class

`app/avo/fields/<name>_field.rb` registers the type and declares its options. Expose each option with an `attr_reader` and read it (with a default) from `args` in `initialize`:

```ruby
# app/avo/fields/progress_bar_field.rb
class Avo::Fields::ProgressBarField < Avo::Fields::BaseField
  attr_reader :max, :step, :display_value, :value_suffix

  def initialize(name, **args, &block)
    super(name, **args, &block)

    @max = args[:max] || 100
    @step = args[:step] || 1
    @display_value = args[:display_value] || false
    @value_suffix = args[:value_suffix] || nil
  end
end
```

`BaseField` also provides typed helpers that read + coerce an arg in one line: `add_boolean_prop(args, :display_value)`, `add_string_prop(args, :value_suffix)`, `add_array_prop`, `add_object_prop`. You still declare the matching `attr_reader`.

Then it's used like any built-in:

```ruby
# app/avo/resources/project.rb
def fields
  field :id, as: :id
  field :progress, as: :progress_bar, step: 10, display_value: true, value_suffix: "%"
end
```

**Visibility:** call the standard helpers inside `initialize` to bake in a default (e.g. `hide_on :forms`), or let users override per usage with `hide_on:` / `only_on:` in the `field` call.

**`table_header_class`:** override this method to return a CSS class for the Index `<th>` (e.g. force a column width with `"w-32"`). Defaults to `nil`.

### The three components

Generated components are plain text fields you replace. Each inherits from an Avo base component (`Avo::Fields::EditComponent`, `ShowComponent`, `IndexComponent`), which exposes what you render with. Available in the `.html.erb` templates:

| Helper / var | Where | What it is |
| --- | --- | --- |
| `@field` | all three | Your field instance. `@field.value`, `@field.id`, `@field.placeholder`, `@field.name`, plus **every `attr_reader` you added** (`@field.max`, …). |
| `@resource`, `@view`, `@index` | all three | The resource, an `Avo::ViewInquirer` (`@view.edit?`, `@view.show?`, …), and the field's position. |
| `field_wrapper_args` | all three | Splat into the wrapper: `field_wrapper **field_wrapper_args`. Carries `@field`, `@resource`, `@view`, and layout flags. |
| `@form` | Edit only | Rails form builder — build inputs with `@form.range_field @field.id`, `@form.text_field @field.id`, etc. |
| `classes("extra")` | Edit only | Input CSS classes with error state / size / HTML overrides already applied. |
| `disabled?` | Edit, Show | `true` when readonly **or** disabled — prefer it over `@field.readonly`, it covers both. |

### The field wrapper (why every component starts with it)

The first thing each component does is wrap your content in `field_wrapper` (Show/Edit) or `index_field_wrapper` (Index). The wrapper is what makes a custom field look native: it draws the **label, required asterisk, help text, validation error, blank-`—` placeholder**, and applies `stacked` / `full_width` / `density` layout. You render only the *value*; the wrapper renders everything around it. That's why you splat `field_wrapper_args` instead of hand-building the label. Pass extra options alongside it (`field_wrapper **field_wrapper_args, dash_if_blank: false`).

Typical customization — a `<progress>` bar on Show, a range slider on Edit:

```erb
<%# show_component.html.erb %>
<%= field_wrapper **field_wrapper_args do %>
  <% if @field.display_value %>
    <div class="text-center text-sm font-semibold w-full leading-none mb-1">
      <%= @field.value %><%= @field.value_suffix if @field.value_suffix.present? %>
    </div>
  <% end %>
  <progress max="<%= @field.max %>" value="<%= @field.value %>" class="block w-full"></progress>
<% end %>
```

```erb
<%# edit_component.html.erb %>
<%= field_wrapper **field_wrapper_args do %>
  <%= @form.range_field @field.id,
    class: "w-full", disabled: disabled?, min: 0,
    max: @field.max, step: @field.step %>
<% end %>
```

Index uses `index_field_wrapper` the same way.

### Pre-built Stimulus controllers

Avo bundles reusable controllers so you don't have to ship JS for common patterns — e.g. `hidden-input`, which collapses content behind a "Show content" trigger (as the Trix field does). Wire it in ERB: put `data-controller="hidden-input"` on a wrapper, add a link with `data: { action: "click->hidden-input#showContent" }`, and mark the collapsible div with `data-hidden-input-target="content"`. See the custom-fields doc for the full markup.

## Gotchas

- **Restart the Rails server after generating the field** — new field types aren't loaded until restart. Most common "it doesn't work" cause; always say it in your report.
- **No automatic asset loading for custom fields.** Avo deliberately doesn't bundle your JS/CSS. Load them through your own Avo asset pipeline (cross-link **avo-custom-ui** / the asset-handling doc). The inline `<script>` in the docs is a demo, not the recommended path — prefer a Stimulus controller.
- **The wrapper renders `—` when `@field.value` is blank**, replacing your block entirely — it checks the *value*, not what your markup draws. If your field renders something meaningful for a `nil`/blank value (an empty widget, a default), pass `dash_if_blank: false` to the wrapper or your content never shows.
- **Non-model fields need getter + setter on the model.** If the field's `id` isn't a real column, Avo can't read or persist it until the model defines both:
  ```ruby
  def custom_field; end
  def custom_field=(value); end
  ```
- **`--field-template` clones an existing built-in**; the copied components/config carry the original's code renamed to your field. Great starting point when you want text/number/etc. behavior plus a tweak — but you inherit its options too, so trim what you don't need.
- **Editing a built-in field's look ≠ authoring a new type.** To restyle an existing type in place, eject its components: `bin/rails generate avo:eject --field-components text`. To override them only in some resources (not globally), add `--scope <name>` and point the resource/field's `components:` option at the scoped copy. Ejecting without `--scope` replaces that field everywhere. This is the eject-views path, not `avo:field`.
- **Shipping a field type inside a gem** (not an app) uses a different entry point: `Avo.plugin_manager.register_field :your_type, YourGem::Fields::YourField` in the plugin. See the plugins doc — the `avo:field` generator is for app-local fields.
- **Don't fire on "add a field".** Adding/changing a normal field is the **avo-fields** skill. This skill only applies when a genuinely new type is being authored.

## Report

After building the field, tell the user:

- The generator command run and the four files created (`app/avo/fields/<name>_field.rb` + the three component pairs under `app/components/avo/fields/<name>_field/`).
- The `as:` value they now use in a resource (`field :x, as: :<name>`) and any options the field accepts (each `attr_reader` + its default).
- **That they must restart the Rails server** before the field appears.
- Any JS/CSS the field needs and that it must be wired through their own Avo asset pipeline (point to avo-custom-ui), plus any model getter/setter required for a non-model value.
- If you cloned with `--field-template`, which type you started from.
