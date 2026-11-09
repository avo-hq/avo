// Tagify parses these templates as HTML. It has already escaped a tag's value, but not the suggestion's other keys.
const escapeHTML = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => `&#${char.charCodeAt(0)};`)

export function tagTemplate(tagData) {
  const suggestions = this.settings.whitelist || []

  const possibleSuggestion = suggestions.find(
    // eslint-disable-next-line eqeqeq
    (item) => item.value == tagData.value,
  )
  const possibleLabel = possibleSuggestion && 'label' in possibleSuggestion
    ? escapeHTML(possibleSuggestion.label)
    : tagData.value

  return `
<tag title="${tagData.value}"
  contenteditable='false'
  spellcheck='false'
  tabIndex="-1"
  class="tagify__tag ${escapeHTML(tagData.class)}"
  ${this.getAttributes(tagData)}
>
  <x title='' class=' tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
  <div>
      <span class='tagify__tag-text'>${possibleLabel}</span>
  </div>
</tag>
`
}

export function suggestionItemTemplate(tagData) {
  return `
<div ${this.getAttributes(tagData)}
  class='tagify__dropdown__item dropdown-menu__item ${escapeHTML(tagData.class)}'
  tabindex="0"
  role="option">
  ${tagData.avatar
    ? `
  <div class='rounded-sm w-8 h-8 block me-2'>
      <img onerror="this.style.visibility='hidden'" class="w-full" src="${escapeHTML(tagData.avatar)}">
  </div>`
    : ''
}
  <span>${escapeHTML(tagData.label)}</span>
</div>
`
}
