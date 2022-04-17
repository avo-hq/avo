export function tagTemplate(tagData) {
  const suggestions = this.settings.whitelist || []

  const possibleSuggestion = suggestions.find(
    // eslint-disable-next-line eqeqeq
    (item) => item.value == tagData.value,
  )
  const possibleLabel = possibleSuggestion
    ? possibleSuggestion.label
    : tagData.value

  return `
<tag title="${tagData.value}"
  contenteditable='false'
  spellcheck='false'
  tabIndex="-1"
  class="tagify__tag ${tagData.class ? tagData.class : ''}"
  ${this.getAttributes(tagData)}
>
  <x title='' class='tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
  <div>
      <span class='tagify__tag-text'>${possibleLabel}</span>
  </div>
</tag>
`
}

export function suggestionItemTemplate(tagData) {
  return `
<div ${this.getAttributes(tagData)}
  class='tagify__dropdown__item flex items-center ${
  tagData.class ? tagData.class : ''
}'
  tabindex="0"
  role="option">
  ${
  tagData.avatar
    ? `
  <div class='rounded w-8 h-8 block mr-2'>
      <img onerror="this.style.visibility='hidden'" class="w-full" src="${tagData.avatar}">
  </div>`
    : ''
}
  <span>${tagData.label}</span>
</div>
`
}
