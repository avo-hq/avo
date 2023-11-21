import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

export default class extends Controller {
  static targets = ['urlRedirect']

  static values = {
    keepFiltersPanelOpen: Boolean,
  }

  // eslint-disable-next-line class-methods-use-this
  uriParams() {
    return URI(window.location.toString()).query(true)
  }

  viaResourceName() {
    return this.uriParams().via_resource_name
  }

  uriParam(param) {
    const viaResourceName = this.viaResourceName()

    if (viaResourceName) return `${this.viaResourceName}_${param}`

    return param
  }

  b64EncodeUnicode(str) {
    // first we use encodeURIComponent to get percent-encoded UTF-8,
    // then we convert the percent encodings into raw bytes which
    // can be fed into btoa.
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
      (match, p1) => String.fromCharCode(`0x${p1}`)))
  }

  b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map((c) => `%${(`00${c.charCodeAt(0).toString(16)}`).slice(-2)}`).join(''))
  }

  changeFilter() {
    const value = this.getFilterValue()
    const filterClass = this.getFilterClass()

    // Get the `filters` param for all params
    let filters = this.uriParams()[this.uriParam('filters')]

    // Decode the filters
    if (filters) {
      filters = JSON.parse(this.b64DecodeUnicode(filters))
    } else {
      filters = {}
    }

    // Get the values for this particular filter
    filters[filterClass] = value

    const filtered = Object.keys(filters)
      // Filter out the filters without a value
      .filter((key) => filters[key] !== null)
      .reduce((obj, key) => {
        obj[key] = filters[key]

        return obj
      }, {})

    let encodedFilters

    // Encode the filters and their values
    if (filtered && Object.keys(filtered).length > 0) {
      encodedFilters = this.b64EncodeUnicode(JSON.stringify(filtered))
    }

    this.navigateToURLWithFilters(encodedFilters)
  }

  navigateToURLWithFilters(encodedFilters) {
    // Create a new URI with them
    const url = new URI(this.urlRedirectTarget.href)

    const query = {
      ...url.query(true),
    }

    if (this.keepFiltersPanelOpenValue) {
      // eslint-disable-next-line camelcase
      query.keep_filters_panel_open = this.keepFiltersPanelOpenValue ? 1 : null
    }

    // force to go to the first page if the filters changed
    query.page = 1

    if (encodedFilters) {
      query.filters = encodedFilters
    } else {
      delete query.filters
    }

    url.query(query)

    this.urlRedirectTarget.href = url.readable().toString()
    this.urlRedirectTarget.click()
  }
}
