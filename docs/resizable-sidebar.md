# Resizable sidebar

On desktop, the boundary between the sidebar and the content is a drag handle. Users drag it to whatever width suits their navigation labels, and the choice sticks across pages and browser restarts.

The handle is deliberately quiet: at rest there is nothing new to see — the divider is the same one Avo has always drawn — and the affordance announces itself through the `col-resize` cursor when the pointer crosses the boundary. A grip appears on hover and while dragging. Double-clicking the handle resets the sidebar to its starting width, and pressing <kbd>Escape</kbd> mid-drag cancels the drag and reverts to the width it started from.

## Bounds

Widths are clamped to **200px–480px**, and never wider than 40% of the viewport, so the content area cannot be squeezed out on a narrower screen. If a user picks 480px on a wide monitor and later opens the same admin on a 1100px window, the sidebar renders narrower to fit and returns to 480px when there is room again — the stored preference is not overwritten.

## Truncated labels

Sidebar labels no longer wrap: a link, section, or group name that overflows renders on a single line with an ellipsis, and the full label is available in a tooltip on hover. This applies at every width, so even the 200px minimum stays tidy.

## Persistence

The chosen width is stored in a cookie and applied before the first paint, so there is no flash of the default width on load.

The width is stored **per browser**, not per user — two people sharing a browser profile share a width, the same as Avo's theme and per-page preferences. It does not sync across devices.

## Desktop only

Resizing is desktop-only. Below the `lg` breakpoint (1024px) the sidebar is a full-height overlay, so there is no handle and no resizing — the sidebar uses its default width there regardless of what was chosen on desktop. The handle is also hidden on touch devices and anywhere without a precise pointer.

## Change the starting width

Set `Avo.configuration.sidebar_default_width` to change where the sidebar starts before a user drags it — useful when your resource names are consistently long.

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.sidebar_default_width = 320
end
```

The value is in pixels and is clamped to the same 200–480 range as dragging, so the handle can always drag back to it. A value Avo cannot read as an integer falls back to `256` rather than clamping to the minimum.

It applies on desktop only; below `lg` the sidebar keeps its 256px default so a wide value cannot cover a small screen. A user who has dragged the sidebar keeps their own width — their preference wins over this setting.

| Property | Value                              |
| -------- | ---------------------------------- |
| Type     | Integer                            |
| Default  | `256`                              |
| Range    | `200`–`480` (outside is clamped)   |

## Turn resizing off

Set `Avo.configuration.sidebar_resizable` to `false` to remove the handle entirely. The sidebar then stays at its configured width and behaves exactly as it did before.

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.sidebar_resizable = false
end
```

> [!WARNING]
> Resizing is a drag-only gesture, which does not satisfy [WCAG 2.2 SC 2.5.7 (Dragging Movements)](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html). If you are working to an AA conformance claim or a VPAT, use this option to opt out.

## Without JavaScript

The stored width is applied by a small nonce'd script in `<head>`, so with JavaScript disabled the sidebar renders at its default width and no handle appears.
