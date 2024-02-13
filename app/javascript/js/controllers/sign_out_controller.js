import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['element']

  static values = {
    confirm: String,
  }

  /**
  We are intercepting the sign-out submission to clear the cache first.
  By clearing the Turbo cache we are ensuring that when someone presses the back button
  after a sign-out attempt, the cache is not there in the browser and they can't
  navigate back to see sensitive information from the previous page.
  */
  handle(e) {
    e.preventDefault()

    // eslint-disable-next-line no-alert
    if (window.confirm(this.confirmValue)) {
      window.Turbo.cache.clear()

      this.element.submit()
    }
  }
}
