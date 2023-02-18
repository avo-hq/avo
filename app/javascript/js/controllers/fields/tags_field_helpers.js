export function tagTemplate(idAttribute, labelAttribute) {
  return function tagTemplate(tagData) {
    const suggestions = this.settings.whitelist || []

    // eslint-disable-next-line eqeqeq
    const possibleSuggestion = suggestions.find((item) => item[idAttribute] == tagData[idAttribute])
    const possibleLabel = possibleSuggestion
      ? possibleSuggestion[labelAttribute]
      : tagData[idAttribute]

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
}
export function suggestionItemTemplate(idAttribute, labelAttribute) {
  return function suggestionItemTemplate(tagData) {
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
  <span>${tagData[labelAttribute]}</span>
</div>
`
  }
}
