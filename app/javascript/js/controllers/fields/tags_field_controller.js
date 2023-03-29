import { first, isObject, merge } from 'lodash'
import Tagify from '@yaireo/tagify'
import URI from 'urijs'

import { suggestionItemTemplate, tagTemplate } from './tags_field_helpers'
import BaseController from '../base_controller'
import debouncePromise from '../../helpers/debounce_promise'

export default class extends BaseController {
  static targets = ['input', 'fakeInput'];

  static values = {
    whitelistItems: { type: Array, default: [] },
    disallowedItems: { type: Array, default: [] },
    enforceSuggestions: { type: Boolean, default: false },
    closeOnSelect: { type: Boolean, default: false },
    delimiters: { type: Array, default: [] },
    mode: String,
    fetchValuesFrom: String,
  }

  tagify = null;

  searchDebounce = 500

  debouncedFetch = debouncePromise(fetch, this.searchDebounce);

  get suggestionsAreObjects() {
    return isObject(first(this.whitelistItemsValue)) || this.fetchValuesFromValue
  }

  get tagifyOptions() {
    let options = {
      whitelist: this.whitelistItemsValue,
      blacklist: this.disallowedItemsValue,
      enforceWhitelist: this.enforceSuggestionsValue || this.fetchValuesFromValue,
      delimiters: this.delimitersValue.join('|'),
      dropdown: {
        maxItems: 20,
        enabled: 0,
        searchKeys: [this.labelAttributeValue],
        closeOnSelect: this.closeOnSelectValue,
      },
    }

    if (this.modeValue) {
      options.mode = this.modeValue // null or "select"
    }

    if (this.suggestionsAreObjects) {
      options = merge(options, {
        tagTextProp: 'label',
        dropdown: {
          searchKeys: ['label'],
          mapValueTo: 'value',
        },
        templates: {
          tag: tagTemplate,
          dropdownItem: suggestionItemTemplate,
        },
        originalInputValueFormat: (valuesArr) => valuesArr.map((item) => item.value),
      })
    } else {
      options = merge(options, {
        originalInputValueFormat: (valuesArr) => valuesArr.map((item) => item.value).join(','),
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
    const that = this

    function onInput(e) {
      // Create the URL from which to fetch the values
      const query = e.detail.value
      const uri = new URI(that.fetchValuesFromValue)
      uri.addSearch({
        q: query,
      })

      // reset current whitelist
      that.tagify.whitelist = null
      // show the loader animation
      that.tagify.loading(true)

      // get new whitelist from a request
      that.fetchResults(uri.toString())
        .then((result) => {
          that.tagify.settings.whitelist = result // add already-existing tags to the new whitelist array

          that.tagify
            .loading(false)
            .dropdown.show(e.detail.value) // render the suggestions dropdown.
        })
        .catch(() => that.tagify.dropdown.hide())
    }

    if (this.fetchValuesFromValue) {
      this.tagify.on('input', onInput)
    }
  }

  fetchResults(endpoint) {
    return this.debouncedFetch(endpoint)
      .then((response) => response.json())
  }

  hideFakeInput() {
    this.fakeInputTarget.classList.add('hidden')
  }

  showRealInput() {
    this.inputTarget.classList.remove('hidden')
  }
}
