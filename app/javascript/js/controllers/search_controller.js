/* eslint-disable no-underscore-dangle */
import * as Mousetrap from 'mousetrap'
import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { autocomplete } from '@algolia/autocomplete-js'
import URI from 'urijs'
import debouncePromise from '../helpers/debounce_promise'

/**
 * The search controller is used in three places.
 * 1. Global search (on the top navbar) and can search through multiple resources.
 * 2. Resource search (on the Index page on top of the table panel) and will search one resource
 * 3. belongs_to field. This requires a bit more cleanup because the user will not navigate away from the page.
 * It will replace the id and label in some fields on the page and also needs a "clear" button which clears the information so the user can submit the form without a value.
 */
export default class extends Controller {
  static targets = [
    'autocomplete',
    'button',
    'hiddenId',
    'visibleLabel',
    'clearValue',
    'clearButton',
  ];

  debouncedFetch = debouncePromise(fetch, this.searchDebounce);

  get dataset() {
    return this.autocompleteTarget.dataset
  }

  get searchDebounce() {
    return window.Avo.configuration.search_debounce
  }

  get translationKeys() {
    let keys
    try {
      keys = JSON.parse(this.dataset.translationKeys)
    } catch (error) {
      keys = {}
    }

    return keys
  }

  get isBelongsToSearch() {
    return this.dataset.viaAssociation === 'belongs_to'
  }

  get isGlobalSearch() {
    return this.dataset.searchResource === 'global'
  }

  searchUrl(query) {
    const url = URI()

    let params = { q: query }
    let segments = [
      window.Avo.configuration.root_path,
      'avo_api',
      this.dataset.searchResource,
      'search',
    ]

    if (this.isGlobalSearch) {
      segments = [window.Avo.configuration.root_path, 'avo_api', 'search']
    }

    if (this.isBelongsToSearch) {
      // eslint-disable-next-line camelcase
      params = { ...params, via_association: this.dataset.viaAssociation }
    }

    return url.segment(segments).search(params).toString()
  }

  handleOnSelect({ item }) {
    if (this.isBelongsToSearch) {
      this.hiddenIdTarget.setAttribute('value', item._id)
      this.buttonTarget.setAttribute('value', item._label)

      document.querySelector('.aa-DetachedOverlay').remove()

      this.clearButtonTarget.classList.remove('hidden')
    } else {
      Turbo.visit(item._url, { action: 'advance' })
    }
  }

  addSource(resourceName, data) {
    const that = this

    return {
      sourceId: resourceName,
      getItems: () => data.results,
      onSelect: that.handleOnSelect.bind(that),
      templates: {
        header() {
          return `${data.header.toUpperCase()} ${data.help}`
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
          return that.translationKeys.no_item_found.replace(
            '%{item}',
            resourceName,
          )
        },
      },
    }
  }

  showSearchPanel() {
    this.autocompleteTarget.querySelector('button').click()
  }

  clearValue() {
    this.clearValueTargets.map((e) => e.setAttribute('value', ''))
    this.clearButtonTarget.classList.add('hidden')
  }

  connect() {
    const that = this

    this.buttonTarget.onclick = () => this.showSearchPanel()

    this.clearValueTargets.forEach((target) => {
      if (target.getAttribute('value')) {
        this.clearButtonTarget.classList.remove('hidden')
      }
    })

    if (this.isGlobalSearch) {
      Mousetrap.bind(['command+k', 'ctrl+k'], () => this.showSearchPanel())
    }

    autocomplete({
      container: this.autocompleteTarget,
      placeholder: this.translationKeys.placeholder,
      translations: {
        detachedCancelButtonText: this.translationKeys.cancel_button,
      },
      openOnFocus: true,
      detachedMediaQuery: '',
      getSources: ({ query }) => {
        const endpoint = that.searchUrl(query)

        return that
          .debouncedFetch(endpoint)
          .then((response) => response.json())
          .then((data) => Object.keys(data).map((resourceName) => that.addSource(resourceName, data[resourceName])))
      },
    })

    this.buttonTarget.removeAttribute('disabled')
  }
}
