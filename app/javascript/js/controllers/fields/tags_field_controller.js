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
    idAttribute: String,
    labelAttribute: String,
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

    // console.log('this.modeValue->', this.modeValue)
    if (this.modeValue) {
      options.mode = this.modeValue // null or "select"
    }

    if (this.suggestionsAreObjects) {
      options = merge(options, {
        tagTextProp: 'label',
        dropdown: {
          searchKeys: ['label'],
        },
        templates: {
          tag: tagTemplate(this.idAttributeValue, this.labelAttributeValue),
          dropdownItem: suggestionItemTemplate(this.idAttributeValue, this.labelAttributeValue),
        },
      })
    }

    // If the value attribute is present use that key of the object as the field value.
    // If not, let the field use the object that was originally received.
    //
    // In some cases the user might want the full object from selection ({value: 101, label: "Adrian"}) instead of just one attribute (101)
    // For that scenario we hardcode a "nil" string to tell Avo to pass that object further.
    if (this.idAttributeValue) {
      options.originalInputValueFormat = (valuesArr) => valuesArr.map((item) => item[this.idAttributeValue])
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
