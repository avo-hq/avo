import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "track", "circle"]

  connect() {
    this.checkboxTarget.addEventListener('change', this.toggle.bind(this))
  }

  disconnect() {
    this.checkboxTarget.removeEventListener('change', this.toggle.bind(this))
  }

  toggle(event) {
    const isChecked = this.checkboxTarget.checked
    
    //track background color
    this.trackTarget.style.backgroundColor = isChecked ? '#3b82f6' : '#d1d5db'
    
    //circle position
    this.circleTarget.style.transform = isChecked ? 'translateX(20px)' : 'translateX(0px)'
  }

}