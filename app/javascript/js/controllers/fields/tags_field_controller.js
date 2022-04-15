import { Controller } from '@hotwired/stimulus'
import { first, isObject, merge } from 'lodash'
import Tagify from '@yaireo/tagify'

function tagTemplate(tagData) {
  const suggestions = this.settings.whitelist || []

  // eslint-disable-next-line eqeqeq
  const possibleSuggestion = suggestions.find((item) => item.value == tagData.value)
  const possibleLabel = possibleSuggestion ? possibleSuggestion.label : tagData.value

  return `
<tag title="${tagData.email}"
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

function suggestionItemTemplate(tagData) {
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

export default class extends Controller {
  static targets = ['input'];

  tagify = null;

  get suggestions() {
    return this.getJsonDataAttribute(this.inputTarget, 'data-suggestions', [])
  }

  get enforceSuggestions() {
    return this.inputTarget.getAttribute('data-enforce-suggestions') === '1'
  }

  get closeOnSelect() {
    return this.inputTarget.getAttribute('data-close-on-select') === '1'
  }

  get delimiters() {
    return this.getJsonDataAttribute(this.inputTarget, 'data-delimiters', [])
  }

  get suggestionsAreObjects() {
    return isObject(first(this.suggestions))
  }

  connect() {
    let options = {
      whitelist: this.suggestions,
      enforceWhitelist: this.enforceSuggestions,
      delimiters: this.delimiters.join('|'),
      maxTags: 10,
      dropdown: {
        maxItems: 20,
        enabled: 0,
        closeOnSelect: this.closeOnSelect,
      },
    }

    if (this.suggestionsAreObjects) {
      options = merge(options, {
        tagTextProp: 'label',
        dropdown: {
          searchKeys: ['label'],
        },
        templates: {
          tag: tagTemplate,
          dropdownItem: suggestionItemTemplate,
        },
      })
    }

    if (this.hasInputTarget) {
      this.tagify = new Tagify(this.inputTarget, options)
    }
  }

  getJsonDataAttribute(target, attribute, defaultValue = []) {
    let result = defaultValue
    try {
      result = JSON.parse(target.getAttribute(attribute))
    } catch (error) {}

    return result
  }
}
