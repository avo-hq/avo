import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['emailField', 'firstNameTextWrapper']

  connect() {
    console.log('BASE resource_show_controller', this.context.targets, this.constructor.targets)
    console.log('this.firstNameTextWrapperTarget->', this.firstNameTextWrapperTarget)
  }

  emailUpdate(e) {
    console.log('BASE emailUpdate->', e, e.target.value)
  }

  atInput(e) {
    console.log('BASE At Input ()->', e, e.target.value)
  }
}
