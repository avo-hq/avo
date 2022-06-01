import Controller from '../resource_edit_controller'

export default class extends Controller {
  static targets = ['parentController', 'skillsTagsWrapper']

  static values = {
    view: String,
  }

  connect() {
    // const parentController = this.application.getControllerForElementAndIdentifier(this.parentControllerTarget, `resource-${this.viewValue}`)
    // console.log('Parent controller->', parentController.viewValue, this.viewValue)
  }

  toggle() {
    this.skillsTagsWrapperTarget.classList.toggle('hidden')
  }
}
