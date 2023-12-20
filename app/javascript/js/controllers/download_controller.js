import { Controller } from '@hotwired/stimulus'
import { saveAs } from 'file-saver'

export default class extends Controller {
  connect() {
    saveAs(
      new Blob([this.element.dataset.content]),
      this.element.dataset.filename,
    )
  }
}
