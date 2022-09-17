import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

export default class extends Controller {
  static targets = ['select']

  get parentTurboFrame() {
    return this.context.scope.element.closest('turbo-frame')
  }

  onChange(e) {
    if (!this.parentTurboFrame.src) return

    // Get the frame URL
    const url = new URI(this.parentTurboFrame.src)
    // update the url with the new range param
    url.search({ ...url.query(true), range: e.currentTarget.value })
    // change the src of the frame
    this.parentTurboFrame.src = url.toString()
    // reload the frame with new range
    this.parentTurboFrame.reload()
  }
}
