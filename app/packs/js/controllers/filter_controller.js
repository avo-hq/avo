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

  b64EncodeUnicode(str) {
    // first we use encodeURIComponent to get percent-encoded UTF-8,
    // then we convert the percent encodings into raw bytes which
    // can be fed into btoa.
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
      function toSolidBytes(match, p1) {
        return String.fromCharCode('0x' + p1);
      }));
  }

  b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
  }

  changeFilter() {
    const value = this.getFilterValue()
    const filterClass = this.getFilterClass()

    let filters = this.uriParams()[this.uriParam('filters')]

    if (filters) {
      filters = JSON.parse(this.b64DecodeUnicode(filters))
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
      encodedFilters = this.b64EncodeUnicode(JSON.stringify(filtered))
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
