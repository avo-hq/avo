// import { Controller } from '@hotwired/stimulus'
import Controller from '../resource_edit_controller'
// import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['skillsTagsWrapper']

  connect() {
    // useClickOutside(this)
    console.log('connect->', this.skillsTagsWrapperTarget)
  }

  // clickOutside() {
  //   this.panelTarget.classList.add('hidden')
  // }

  toggle() {
    console.log('toggle->')

    this.skillsTagsWrapperTarget.classList.toggle('hidden')
  }
}
