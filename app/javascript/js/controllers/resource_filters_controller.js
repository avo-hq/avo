import BaseFilterController from './filter_controller'

const FILTER_CONTROLLER_IDENTIFIERS = [
  'date-time-filter',
  'multiple-select-filter',
  'text-filter',
]

export default class extends BaseFilterController {
  static values = {
    keepFiltersPanelOpen: Boolean,
  }

  connect() {
    const urlHasKeepOpen = new URLSearchParams(window.location.search).get('keep_filters_panel_open') === '1'
    const resourceWantsKeepOpen = this.keepFiltersPanelOpenValue
    const popover = this.element.querySelector('[popover]')

    if (!popover) return

    if (urlHasKeepOpen && resourceWantsKeepOpen) {
      // Suppress the slide-down transition so the panel appears instantly
      // (avoids the flicker on full-page navigations with keep_filters_panel_open)
      popover.style.transition = 'none'
      popover.showPopover()
      this.rafId = requestAnimationFrame(() => { popover.style.transition = '' })
    }
  }

  disconnect() {
    cancelAnimationFrame(this.rafId)
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
