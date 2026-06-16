import nearestTopLayer from './top_layer'

// Tagify appends its suggestions dropdown to <body>, so a dropdown opened from
// inside a top-layer modal renders underneath it (see ./top_layer for the why).
//
// `tagifyAppendTarget` is passed as Tagify's `dropdown.appendTarget` so the
// dropdown mounts into the nearest top-layer ancestor when there is one, and
// keeps Tagify's normal <body> behaviour everywhere else.
export function tagifyAppendTarget(element) {
  return nearestTopLayer(element) ?? document.body
}

// Once the dropdown lives inside the modal, Tagify still mis-positions it.
// Tagify converts the input's viewport rect into append-target coordinates by
// subtracting the append target's in-flow ancestor offsets — correct for a
// statically-positioned target, but wrong for Avo's modal, which is a
// `position: fixed`, inset:0 popover (no transform). Its absolutely-positioned
// children are anchored to the viewport, so subtracting the modal's in-flow
// offset throws the dropdown thousands of px away (its `top` goes negative).
//
// We let Tagify do all of its own work (placement flip, width, RTL) and then
// re-anchor the dropdown to the input's viewport rect, honoring the above/below
// placement Tagify chose. Installing this by wrapping `dropdown.position` (not a
// one-off `dropdown:show` listener) means it re-runs on *every* Tagify
// reposition — the capture-phase document scroll listener, window resize,
// autocomplete highlight — each of which rewrites the dropdown's inline styles.
// Without that, those repositions would put the dropdown back thousands of px
// away mid-interaction, so it looks like it closes when the cursor moves to it.
export function installTagifyTopLayerPositioning(tagify) {
  const reposition = tagify.dropdown.position

  tagify.dropdown.position = (ddHeight) => {
    reposition(ddHeight)
    anchorDropdownToInput(tagify, ddHeight)
  }
}

function anchorDropdownToInput(tagify, ddHeight) {
  const dropdown = tagify.DOM.dropdown

  if (!nearestTopLayer(tagify.DOM.scope) || !dropdown) return

  const anchor = tagify.DOM.scope.getBoundingClientRect()
  // Tagify passes the measured height while the dropdown is still detached (it
  // positions before appending); fall back to offsetHeight once it's in the DOM.
  const height = ddHeight || dropdown.offsetHeight
  const placeAbove = dropdown.getAttribute('placement') === 'top'
  const top = placeAbove ? anchor.top - height : anchor.bottom

  // The dropdown is absolute inside the fixed, inset:0 modal, so viewport
  // coordinates map straight onto it.
  dropdown.style.top = `${Math.round(top)}px`
  dropdown.style.left = `${Math.round(anchor.left)}px`
}
