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

// https://stackoverflow.com/a/77850750/9067704
StreamActions.download = function () {
  const byteCharacters = atob(this.getAttribute('content'))
  const byteNumbers = new Array(byteCharacters.length)
  for (let i = 0; i < byteCharacters.length; i++) {
    byteNumbers[i] = byteCharacters.charCodeAt(i)
  }
  const byteArray = new Uint8Array(byteNumbers)

  saveAs(
    new Blob(
      [byteArray],
    ),
    this.getAttribute('filename'),
  )
}

// TODO: move to kanban
// TODO: rename this method
StreamActions.reload_boards = function () {
  window.dispatchEvent(new CustomEvent('avo-reload_boards'))
}
