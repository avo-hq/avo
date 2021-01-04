import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ "name", "output" ]

  greet() {
    console.log('this.outputTarget->', this.outputTarget)
    this.outputTarget.textContent = `Hello, ${this.nameTarget.value}!`
  }
}
