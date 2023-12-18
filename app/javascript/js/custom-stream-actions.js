/* eslint-disable camelcase */
import { StreamActions } from '@hotwired/turbo'

StreamActions.close_modal = function () {
  document.querySelector('turbo_frame#actions_show').innerHTML = ''
  document.querySelector('turbo_frame#attach_modal').innerHTML = ''
}

// TODO: move these to the avo_filters gem

StreamActions.close_filters_dropdown = function () {
  document.querySelector('.filters-dropdown-selector').classList.add('hidden')
}

StreamActions.open_filter = function () {
  const id = this.getAttribute('unique-id')
  setTimeout(() => {
    document.querySelector(`[data-filter-id="${id}"] .pill`).click()
  }, 150)
}
