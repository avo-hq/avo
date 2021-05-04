/* eslint-disable no-underscore-dangle */
import * as Mousetrap from 'mousetrap'
import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { autocomplete } from '@algolia/autocomplete-js'
import debouncePromise from '@/js/helpers/debounce_promise'

function addSource(resourceName, data, translationKeys) {
  return {
    sourceId: resourceName,
    getItems: () => data.results,
    onSelect({ item }) {
      Turbo.visit(item._url, { action: 'replace' })
    },
    templates: {
      header() {
        return data.header
      },
      item({ item, createElement }) {
        let element = ''

        if (item._avatar) {
          let classes

          switch (item._avatar_type) {
            default:
            case 'circle':
              classes = 'rounded-full'
              break
            case 'rounded':
              classes = 'rounded'
              break
          }

          element += `<img src="${item._avatar}" alt="${item._label}" class="flex-shrink-0 w-8 h-8 my-[2px] inline mr-2 ${classes}" />`
        }
        element += `<div>${item._label}`

        if (item._description) {
          element += `<div class="aa-ItemDescription">${item._description}</div>`
        }

        element += '</div>'

        return createElement('div', {
          class: 'flex',
          dangerouslySetInnerHTML: {
            __html: element,
          },
        })
      },
      noResults() {
        return translationKeys.no_item_found.replace('%{item}', resourceName)
      },
    },
  }
}

const debouncedFetch = debouncePromise(fetch, 300)

export default class extends Controller {
  static targets = ['autocomplete', 'button']

  get translationKeys() {
    let keys
    try {
      keys = JSON.parse(this.autocompleteTarget.dataset.translationKeys)
    } catch (error) {
      keys = {}
    }

    return keys
  }

  get searchResource() {
    return this.autocompleteTarget.dataset.searchResource
  }

  get isGlobalSearch() {
    return this.searchResource === 'global'
  }

  get searchUrl() {
    return this.isGlobalSearch ? '/avo/avo_api/search' : `/avo/avo_api/${this.searchResource}/search`
  }

  showSearchPanel() {
    this.autocompleteTarget.querySelector('button').click()
  }

  connect() {
    const that = this

    this.buttonTarget.onclick = () => this.showSearchPanel()

    if (this.isGlobalSearch) {
      Mousetrap.bind(['command+k', 'ctrl+k'], () => this.showSearchPanel())
    }

    autocomplete({
      container: this.autocompleteTarget,
      placeholder: 'Search',
      openOnFocus: true,
      detachedMediaQuery: '',
      getSources: ({ query }) => {
        const endpoint = `${that.searchUrl}?q=${query}`

        return debouncedFetch(endpoint)
          .then((response) => response.json())
          .then((data) => Object.keys(data).map((resourceName) => addSource(resourceName, data[resourceName], that.translationKeys)))
      },
    })
  }
}
