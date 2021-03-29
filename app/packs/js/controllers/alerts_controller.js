import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['container']

  connect() {
    window.toastr[this.type](this.message)
  }

  get type() {
    const typeMap = {
      info: 'info',
      warning: 'warning',
      success: 'success',
      error: 'error',
      notice: 'info',
      alert: 'error',
    }

    return typeMap[this.containerTarget.dataset.alertType]
  }

  get message() {
    return this.containerTarget.innerHTML
  }
}
