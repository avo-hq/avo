import BaseFilterController from './filter_controller'

const FILTER_CONTROLLER_IDENTIFIERS = [
  'date-time-filter',
  'multiple-select-filter',
  'text-filter',
]

export default class extends BaseFilterController {
  connect() {
    if (new URLSearchParams(window.location.search).get('keep_filters_panel_open') === '1') {
      this.element.querySelector('[popover]')?.showPopover()
    }
  }

  applyFilters(event) {
    event?.preventDefault()

    let filters = this.uriParams()[this.uriParam(this.PARAM_KEY)]

    if (filters) {
      filters = this.decode(filters)
    } else {
      filters = {}
    }

    FILTER_CONTROLLER_IDENTIFIERS.forEach((identifier) => {
      this.filterElements(identifier).forEach((element) => {
        const controller = this.application.getControllerForElementAndIdentifier(element, identifier)

        if (!controller) return

        filters[controller.getFilterClass()] = controller.getFilterValue()
      })
    })

    const filtered = Object.fromEntries(
      Object.entries(filters).filter(([, value]) => value !== null),
    )

    this.navigateToURLWithFilters(
      Object.keys(filtered).length > 0 ? this.encode(filtered) : null,
    )
  }

  filterElements(identifier) {
    return this.element.querySelectorAll(`[data-controller~="${identifier}"]`)
  }
}
