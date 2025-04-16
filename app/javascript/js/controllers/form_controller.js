import { FormDirtyConfirmNavigationController } from 'stimulus-library'

// Connects to data-controller="form"
export default class extends FormDirtyConfirmNavigationController {
  submit(event) {
    // return if event.key is undefined preventing the form submit on autocomplete event
    if (!event.key) return

    this.element.requestSubmit()
  }

  /*eslint no-underscore-dangle:*/
  _enable() {
    if (this._enabled) {
      return
    }

    super._enable()

    // Push dummy state to intercept back button
    history.pushState(null, '');
    this._historyTrapActive = true
  }

  _disable() {
    super._disable()

    if (this._historyTrapActive) {
      this._historyTrapActive = false
      history.back() // remove dummy history entry
    }
  }

  _confirmNavigation() {
    if (!this._enabled || !this._historyTrapActive) return;

    if (confirm(this._message)) {
      this._disable()
      history.back() // go to previous page
    } else {
      history.pushState(null, '') // stay on page
    }
  }
}
