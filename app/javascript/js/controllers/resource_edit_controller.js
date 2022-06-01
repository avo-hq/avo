import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['skillsTagsWrapper']

  // connect() {
  //   console.log('BASE resource_edit_controller', this.context.targets, this.constructor.targets)
  //   // console.log('this.firstNameTextWrapperTarget->', this.firstNameTextWrapperTarget)
  // }

  // emailUpdate(e) {
  //   console.log('Updated field->', e, e.target.value)
  // }

  atInput(e) {
    console.log('BASE At Input ()->', e, e.target.value)
    // for trix use the innerHTML property
    // console.log('BASE At Input ()->', e, e.target.innerHTML)
  }

  toggle() {
    console.log('toggle->', this.skillsTagsWrapperTarget)
    this.skillsTagsWrapperTarget.classList.toggle('hidden')
  }
}
