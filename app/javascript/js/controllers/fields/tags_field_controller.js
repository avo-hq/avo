import { Controller } from '@hotwired/stimulus'
import { first, isObject, merge } from 'lodash'
import Tagify from '@yaireo/tagify'

import { suggestionItemTemplate, tagTemplate } from './tags_field_helpers'

export default class extends Controller {
  static targets = ['input', 'fakeInput'];

  tagify = null;

  get whitelistItems() {
    return this.getJsonDataAttribute(this.inputTarget, 'data-whitelist-items', [])
  }

  get blacklistItems() {
    return this.getJsonDataAttribute(this.inputTarget, 'data-blacklist-items', [])
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
    return isObject(first(this.whitelistItems))
  }

  get tagifyOptions() {
    let options = {
      whitelist: this.whitelistItems,
      blacklist: this.blacklistItems,
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

    return options
  }

  connect() {
    if (this.hasInputTarget) {
      this.hideFakeInput()
      this.showRealInput()
      this.initTagify()
    }
  }

  getJsonDataAttribute(target, attribute, defaultValue = []) {
    let result = defaultValue
    try {
      result = JSON.parse(target.getAttribute(attribute))
    } catch (error) {}

    return result
  }

  initTagify() {
    this.tagify = new Tagify(this.inputTarget, this.tagifyOptions)
  }

  hideFakeInput() {
    this.fakeInputTarget.classList.add('hidden')
  }

  showRealInput() {
    this.inputTarget.classList.remove('hidden')
  }
}
