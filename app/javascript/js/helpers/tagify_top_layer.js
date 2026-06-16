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

// Tagify positions the dropdown in document coordinates (the anchor's viewport
// position plus the page scroll offset) because it normally lives under <body>.
// Inside a fixed popover the containing block is the viewport itself (the modal
// locks body scroll but keeps pageYOffset), so those document coordinates place
// the dropdown off by the scroll offset. When the dropdown is in a top layer we
// fully own its placement: position it `fixed` against the anchor's viewport
// rect, flipping above the anchor when there isn't room below.
export function positionTagifyDropdownInTopLayer(tagify) {
  const topLayer = nearestTopLayer(tagify.DOM.scope)
  const dropdown = tagify.DOM.dropdown

  if (!topLayer || !dropdown) return

  const anchor = tagify.settings.dropdown.position === 'input' ? tagify.DOM.input : tagify.DOM.scope
  const anchorRect = anchor.getBoundingClientRect()
  const dropdownHeight = dropdown.getBoundingClientRect().height
  const viewportHeight = document.documentElement.clientHeight
  const placeAbove = tagify.settings.dropdown.placeAbove ?? viewportHeight - anchorRect.bottom < dropdownHeight
  const top = placeAbove ? anchorRect.top - dropdownHeight : anchorRect.bottom

  dropdown.style.position = 'fixed'
  dropdown.style.left = `${Math.floor(anchorRect.left)}px`
  dropdown.style.top = `${Math.ceil(top)}px`
  dropdown.style.minWidth = `${Math.ceil(anchorRect.width)}px`
  dropdown.style.maxWidth = `${Math.ceil(anchorRect.width)}px`
  dropdown.setAttribute('placement', placeAbove ? 'top' : 'bottom')
}
