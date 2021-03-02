import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
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
    const encodedFilters = btoa(JSON.stringify(filters))

    const url = new URI(this.urlRedirectTarget.href)

    const query = {
      ...url.query(true),
      filters: encodedFilters,
    }

    url.query(query)

    this.urlRedirectTarget.href = url
    this.urlRedirectTarget.click()
  }
}
