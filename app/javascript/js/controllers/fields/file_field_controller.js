import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['preview']

  update(e) {
    const reader = new FileReader()
    reader.onload = () => {
      this.previewTarget.src = reader.result
    }
    reader.readAsDataURL(e.target.files[0])
  }
}
