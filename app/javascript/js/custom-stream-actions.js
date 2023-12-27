/* eslint-disable camelcase */
import { StreamActions } from '@hotwired/turbo'
import { saveAs } from 'file-saver'

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
// END TODO: move these to the avo_filters gem

StreamActions.download = function() {
  saveAs(
    new Blob(
      [this.getAttribute('content')],
    ),
    this.getAttribute('filename'),
  )
}
