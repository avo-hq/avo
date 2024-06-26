import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    if (window.history.state && window.history.state.turbo) {
      window.addEventListener('popstate', () => { location.reload(true) })
    }
  }
}
