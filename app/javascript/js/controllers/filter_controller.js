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

  decode(filters) {
    return JSON.parse(
      new TextDecoder().decode(
        Uint8Array.from(
          atob(
            decodeURIComponent(filters),
          ), (m) => m.codePointAt(0),
        ),
      ),
    )
  }

  encode(filtered) {
    return encodeURIComponent(
      btoa(
        String.fromCodePoint(
          ...new TextEncoder().encode(
            JSON.stringify(filtered),
          ),
        )
      )
    );
  }

  changeFilter() {
    const value = this.getFilterValue()
    const filterClass = this.getFilterClass()

    // Get the `filters` param for all params
    let filters = this.uriParams()[this.uriParam('filters')]

    // Decode the filters
    if (filters) {
      filters = this.decode(filters)
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
      encodedFilters = this.encode(filtered)
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
