/* eslint-disable no-underscore-dangle */
import * as Mousetrap from 'mousetrap'
import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { autocomplete } from '@algolia/autocomplete-js'

function addSource(resourceName, data) {
  return {
    sourceId: resourceName,
    getItems: () => data.results,
    onSelect({ item }) {
      Turbo.visit(item._url, { action: 'replace' })
    },
    templates: {
      header({ state, source, items }) {
        // console.log('state->', state, items.length)

        return data.header
      },
      item({ item }) {
        return `${item._label}`
      },
      noResults() {
        return `No ${resourceName} found`
      },
    },
  }
}

export default class extends Controller {
  static targets = ['autcomplete', 'button']

  showSearchPanel() {
    this.autcompleteTarget.querySelector('button').click()
  }

  connect() {
    this.buttonTarget.onclick = () => this.showSearchPanel()

    Mousetrap.bind(['command+k', 'ctrl+k'], () => this.showSearchPanel())

    autocomplete({
      container: this.autcompleteTarget,
      placeholder: 'Search',
      openOnFocus: true,
      detachedMediaQuery: '',
      async getSources({ query }) {
        const response = await fetch(`/avo/avo_api/resources/search?q=${query}`)
        const data = await response.json()

        return Object.keys(data).map((resourceName) => addSource(resourceName, data[resourceName]))
      },
    })
  }
}
