import { Controller } from '@hotwired/stimulus'
import { toggle } from 'el-transition'

export default class extends Controller {
  toggleSection(event) {
    const section = event.target.closest("[data-floating-menu-target='section']")
    // toggle(section)
    section.querySelector('[data-floating-menu-target="items"]').classList.toggle('hidden')
  }
}
