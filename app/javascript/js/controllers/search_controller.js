/* eslint-disable no-underscore-dangle */
import * as Mousetrap from 'mousetrap'
import { Controller } from '@hotwired/stimulus'
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

    return url.segment(this.searchSegments()).search(this.searchParams(query)).toString()
  }

  searchSegments() {
    let segments = [
      window.Avo.configuration.root_path,
      'avo_api',
      this.dataset.searchResource,
      'search',
    ]

    if (this.isGlobalSearch) {
      segments = [window.Avo.configuration.root_path, 'avo_api', 'search']
    }

    return segments
  }

  searchParams(query) {
    let params = {
      q: query,
      global: false,
    }

    if (this.isGlobalSearch) {
      params.global = true
    }

    if (this.isBelongsToSearch) {
      params = {
        ...params,
        // eslint-disable-next-line camelcase
        via_association_id: this.dataset.viaAssociationId,
        // eslint-disable-next-line camelcase
        via_reflection_class: this.dataset.viaReflectionClass,
        // eslint-disable-next-line camelcase
        via_reflection_id: this.dataset.viaReflectionId,
        // eslint-disable-next-line camelcase
        via_parent_resource_id: this.dataset.viaParentResourceId,
        // eslint-disable-next-line camelcase
        via_parent_resource_class: this.dataset.viaParentResourceClass,
        // eslint-disable-next-line camelcase
        via_relation: this.dataset.viaRelation,
      }
    }

    return params
  }

  handleOnSelect({ item }) {
    if (this.isBelongsToSearch) {
      this.hiddenIdTarget.setAttribute('value', item._id)
      this.buttonTarget.setAttribute('value', item._label)

      document.querySelector('.aa-DetachedOverlay').remove()

      if (this.hasClearButtonTarget) {
        this.clearButtonTarget.classList.remove('hidden')
      }
    } else {
      Turbo.visit(item._url, { action: 'advance' })
    }

    // On searchable belongs to the class `aa-Detached` remains on the body making it unscrollable
    document.body.classList.remove('aa-Detached')
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
          const children = []

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

            children.push(
              createElement('img', {
                src: item._avatar,
                alt: item._label,
                class: `flex-shrink-0 w-8 h-8 my-[2px] inline mr-2 ${classes}`,
              }),
            )
          }

          const labelChildren = [item._label]
          if (item._description) {
            labelChildren.push(
              createElement(
                'div',
                {
                  class: 'aa-ItemDescription',
                },
                item._description,
              ),
            )
          }

          children.push(createElement('div', null, labelChildren))

          return createElement(
            'div',
            {
              class: 'flex',
            },
            children,
          )
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
      if (target.getAttribute('value') && this.hasClearButtonTarget) {
        this.clearButtonTarget.classList.remove('hidden')
      }
    })

    if (this.isGlobalSearch) {
      Mousetrap.bind(['command+k', 'ctrl+k'], () => this.showSearchPanel())
    }

    const { destroy } = autocomplete({
      container: this.autocompleteTarget,
      placeholder: this.translationKeys.placeholder,
      translations: {
        detachedCancelButtonText: this.translationKeys.cancel_button,
      },
      openOnFocus: true,
      detachedMediaQuery: '',
      getSources: ({ query }) => {
        document.body.classList.add('search-loading')
        const endpoint = that.searchUrl(query)

        return that
          .debouncedFetch(endpoint)
          .then((response) => {
            document.body.classList.remove('search-loading')

            return response.json()
          })
          .then((data) => Object.keys(data).map((resourceName) => that.addSource(resourceName, data[resourceName])))
      },
    })

    document.addEventListener('turbo:before-render', destroy)

    // When using search for belongs-to
    if (this.buttonTarget.dataset.shouldBeDisabled !== 'true') {
      this.buttonTarget.removeAttribute('disabled')
    }
  }
}
