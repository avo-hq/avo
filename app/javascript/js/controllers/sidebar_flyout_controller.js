import { Controller } from '@hotwired/stimulus'

// Hover flyout for a sidebar item whose sub-items aren't already listed inline.
// The panel is a native popover, so it renders in the top layer and escapes the
// sidebar's own `overflow-y: auto` clipping; CSS anchor positioning pins it to
// the item. Also opens on focus, so the list is reachable by keyboard.
export default class extends Controller {
  static targets = ['panel']

  static values = { delay: { type: Number, default: 120 } }

  show() {
    clearTimeout(this.timeout)
    if (!this.panelTarget.matches(':popover-open')) this.panelTarget.showPopover()
  }

  // The panel sits a few pixels off the item, so the pointer is over neither for
  // a frame on the way across. The delay is what lets it make the crossing.
  hide() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      if (this.panelTarget.matches(':popover-open')) this.panelTarget.hidePopover()
    }, this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
