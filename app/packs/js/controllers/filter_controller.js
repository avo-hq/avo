import { Controller } from 'stimulus'
import URI from 'urijs'

export default class extends Controller {
  static targets = ['urlRedirect']

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

  changeFilter() {
    const value = this.getFilterValue()
    const filterClass = this.getFilterClass()

    let filters = this.uriParams()[this.uriParam('filters')]

    if (filters) {
      filters = JSON.parse(atob(filters))
    } else {
      filters = {}
    }

    filters[filterClass] = value

    const filtered = Object.keys(filters)
      .filter((key) => filters[key] !== '')
      .reduce((obj, key) => {
        obj[key] = filters[key]

        return obj
      }, {})

    let encodedFilters

    if (filtered && Object.keys(filtered).length > 0) {
      encodedFilters = btoa(JSON.stringify(filtered))
    }

    const url = new URI(this.urlRedirectTarget.href)

    const query = {
      ...url.query(true),
    }

    if (encodedFilters) {
      query.filters = encodedFilters
    } else {
      delete query.filters
    }

    url.query(query)

    this.urlRedirectTarget.href = url
    this.urlRedirectTarget.click()
  }
}
