import { first, isObject, merge } from 'lodash'
import Tagify from '@yaireo/tagify'

import BaseController from '../base_controller'

import { suggestionItemTemplate, tagTemplate } from './tags_field_helpers'

export default class extends BaseController {
  static targets = ['input', 'fakeInput'];

  tagify = null;

  get whitelistItems() {
    return this.getJsonAttribute(this.inputTarget, 'data-whitelist-items', [])
  }

  get disallowedItems() {
    return this.getJsonAttribute(this.inputTarget, 'data-disallowed-items', [])
  }

  get enforceSuggestions() {
    return this.getBooleanAttribute(this.inputTarget, 'data-enforce-suggestions')
  }

  get closeOnSelect() {
    return this.getBooleanAttribute(this.inputTarget, 'data-close-on-select')
  }

  get delimiters() {
    return this.getJsonAttribute(this.inputTarget, 'data-delimiters', [])
  }

  get suggestionsAreObjects() {
    return isObject(first(this.whitelistItems))
  }

  get tagifyOptions() {
    let options = {
      whitelist: this.whitelistItems,
      blacklist: this.disallowedItems,
      enforceWhitelist: this.enforceSuggestions,
      delimiters: this.delimiters.join('|'),
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
