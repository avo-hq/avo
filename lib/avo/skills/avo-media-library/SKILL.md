---
name: avo-media-library
description: Turn on and manage Avo's Media Library — a central browser/manager for every uploaded asset, plus an asset picker inside the trix, rhino, markdown, and lexxy rich-text editors — configured in config/initializers/avo.rb. Use when the user wants to "let users upload and manage images", "have one place to view and manage all our assets/uploads", "add an image or asset gallery to the admin", "insert/pick an existing image in the rich-text editor while writing content", "reuse uploaded images across records", "a digital asset manager for the admin", or "browse all the files I've uploaded" — and when they want to turn the Media Library on or off, hide or conditionally show its sidebar item, re-add it to a customized menu, or disable the gallery picker on a markdown field. Disabled by default and gated behind `defined?(Avo::MediaLibrary)`; Community license; currently in Alpha (breaking changes expected).
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community (Alpha)
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Enable and manage the Avo Media Library

The Media Library is a central place to browse and manage every asset uploaded to an Avo admin, and it doubles as an asset picker inside Avo's rich-text editors (`trix`, `rhino`, `markdown`, `lexxy`) — a button in each editor opens a modal, and the selected asset is injected into the content. It is **not a separate gem**: it ships inside Avo, gated behind `defined?(Avo::MediaLibrary)`, and is **disabled by default**. All configuration lives in `config/initializers/avo.rb`.

**License:** Community (free). **Status:** Alpha — future releases may contain breaking changes, so tell the user this and point them at the upgrade guide when they adopt it.

**Docs** (fetch on demand — do not rely on memory for exact option names or defaults):
- Docs map / index: https://docs.avohq.io/4.0/docs-map.md
- Media Library guide: https://docs.avohq.io/4.0/media-library.md
- Rich-text fields it plugs into: https://docs.avohq.io/4.0/fields/trix.md · https://docs.avohq.io/4.0/fields/rhino.md · https://docs.avohq.io/4.0/fields/markdown.md · https://docs.avohq.io/4.0/fields/lexxy.md
- Menu editor (for re-adding the item): https://docs.avohq.io/4.0/menu-editor.md
- Blocks / `Avo::Current` in config lambdas: https://docs.avohq.io/4.0/execution-context.md

## When this applies

Reach for this skill when the goal is either of the Media Library's two jobs:

1. **A central asset manager** — one screen to browse and manage all uploaded assets ("a gallery in the admin", "a digital asset manager", "see every file we've uploaded", "reuse images across records").
2. **An asset picker in the editors** — inserting or reusing an existing image while writing rich-text content in a `trix`, `rhino`, `markdown`, or `lexxy` field.

Also use it for the on/off and visibility controls: enabling/disabling the whole feature, hiding or conditionally showing its sidebar item, re-adding it after the menu is customized, and toggling the picker off on a single markdown field.

**Not this skill:**
- Adding or configuring the rich-text field itself (which editor, its options) → **avo-fields**.
- Re-ordering the sidebar, sections/groups, or the global search palette → **avo-navigation-search**.
- Logos, colors, theming, menu/action icons → **avo-branding-appearance**.

## Enable it

The feature is off until you flip the killswitch. Always wrap the config in `if defined?(Avo::MediaLibrary)` so the initializer stays safe if the constant isn't loaded.

```ruby
# config/initializers/avo.rb
if defined?(Avo::MediaLibrary)
  Avo::MediaLibrary.configure do |config|
    config.enabled = true
  end
end
```

`config.enabled` is the killswitch for the entire feature. While it's `false` (the default) the Media Library is unavailable to everyone: the sidebar item is hidden, all its routes are blocked, and the Media Library button is hidden in every editor. Note the block is `Avo::MediaLibrary.configure` (a separate object) — **not** the main `Avo.configure` block.

## Workflow

1. **Find the initializer.** It's `config/initializers/avo.rb`. `Grep` it for `Avo::MediaLibrary` to see whether a `configure` block already exists; add to it rather than creating a second one.

2. **Turn it on** with the `Enable it` snippet above. This is the only step needed for "let users upload/manage assets" or "add an asset gallery". Mention the Alpha status.

3. **Control the sidebar item (optional).** By default an enabled Media Library adds a sidebar item.
   - Hide it outright with a Boolean:
     ```ruby
     if defined?(Avo::MediaLibrary)
       Avo::MediaLibrary.configure do |config|
         config.visible = false
       end
     end
     ```
   - Or show it conditionally with a block. The block runs through Avo's execution context, so it has access to `Avo::Current` (e.g. the current user):
     ```ruby
     if defined?(Avo::MediaLibrary)
       Avo::MediaLibrary.configure do |config|
         config.visible = -> { Avo::Current.user.is_developer? }
       end
     end
     ```
   `visible` only affects the menu item; it does not disable the feature. (When `enabled` is `false`, `visible` is moot — the killswitch already hides everything.)

4. **Re-add it to a customized menu (if needed).** If the app defines a custom `config.main_menu` (see **avo-navigation-search**), the Media Library item does **not** appear automatically. Add it back as a `link_to` (or `link`) pointing at `avo.media_library_index_path`, inside the normal `Avo.configure` block:
   ```ruby
   # config/initializers/avo.rb
   Avo.configure do |config|
     config.main_menu = lambda {
       link_to "Media Library", avo.media_library_index_path
       # ...the rest of the custom menu
     }
   end
   ```

5. **Use it with the editors.** Once enabled, every `trix`, `rhino`, `markdown`, and `lexxy` field automatically gets a Media Library button in its toolbar — no per-field opt-in. Just declare the field as usual (this is **avo-fields** territory):
   ```ruby
   field :body, as: :trix
   field :body, as: :rhino
   field :body, as: :markdown
   field :body, as: :lexxy
   ```

6. **Disable the picker on a single markdown field (optional).** The `markdown` field accepts a `media_library` option (defaults to `true`). Set it to `false` to hide the gallery button on that one field while the Media Library stays enabled everywhere else:
   ```ruby
   field :body, as: :markdown, media_library: false
   ```
   This is **markdown-only** — `trix` and `rhino` have no per-field toggle. To remove the picker from those, the only lever is the global killswitch. The `lexxy` field hides its button when attachments are disabled (`attachments_disabled: true`, the default on plain columns).

7. **Report** what you changed (see below). No need to run the app; a `ruby -c` on the initializer is enough to sanity-check syntax.

## Gotchas

- **Alpha feature.** It's still in alpha and future releases may include breaking changes. Say so, and tell the user to watch the upgrade guide. Don't present it as stable.
- **Always guard with `if defined?(Avo::MediaLibrary)`.** The docs wrap every `Avo::MediaLibrary.configure` call this way. Without the guard, an environment where the constant isn't present would raise on boot.
- **`config.enabled` is an all-or-nothing killswitch.** Flipping it off hides the menu item, blocks the routes, *and* hides the editor icons — for everyone. There is no per-user or per-resource enable; use `config.visible` (a block) if you only want to gate who *sees the menu item*.
- **`enabled` and `visible` are different levers.** `enabled` = whole feature on/off. `visible` = just the sidebar item (Boolean or block). Hiding the item with `visible = false` does not disable uploads or the editor picker.
- **A customized menu drops the item.** If `config.main_menu` is defined, the Media Library sidebar item won't appear on its own — re-add it manually with `link_to "Media Library", avo.media_library_index_path`.
- **`media_library: false` is markdown-only.** `trix` and `rhino` don't support per-field toggling; the killswitch is the only way to remove their buttons. `lexxy` follows its own `attachments_disabled` option.
- **It's `Avo::MediaLibrary.configure`, not `Avo.configure`.** The enable/visible settings live on their own configuration object. Only the menu `link_to` goes inside the main `Avo.configure` block.

## Report

After editing, tell the user:

- The file you changed (`config/initializers/avo.rb`) and which block (`Avo::MediaLibrary.configure` and/or `Avo.configure`).
- What you set: `config.enabled`, `config.visible` (Boolean or block), any `link_to` menu item, and any `media_library: false` on a markdown field.
- That the feature is **Community-licensed** but in **Alpha**, so breaking changes are possible — watch the upgrade guide.
- Whether the sidebar item will show, and for whom (if you used a `visible` block).
- If they customized their menu: remind them the item only appears because you re-added the `link_to`.
