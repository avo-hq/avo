import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = []

  static values = {
    view: String,
  }

  connect() {
    console.log('BASE resource_edit_controller', this.context.targets, this.constructor.targets, 1, this.viewValue)
    // this.application.getControllerForElementAndIdentifier(this.otherTarget, 'other')
    // console.log('this.firstNameTextWrapperTarget->', this.firstNameTextWrapperTarget)
  }

  // emailUpdate(e) {
  //   console.log('Updated field->', e, e.target.value)
  // }

  atInput(e) {
    console.log('BASE At Input ()->', e, e.target.value, this.viewValue)
    // for trix use the innerHTML property
    // console.log('BASE At Input ()->', e, e.target.innerHTML)
  }

  // toggle() {
  //   console.log('toggle->', this.skillsTagsWrapperTarget)
  //   this.skillsTagsWrapperTarget.classList.toggle('hidden')
  // }
}
