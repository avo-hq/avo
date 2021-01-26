import { Controller } from 'stimulus'
import tippy, {roundArrow} from 'tippy.js'
import 'tippy.js/dist/svg-arrow.css'

export default class extends Controller {
  static targets = ['trigger', 'content']

  connect() {
    tippy(this.triggerTarget, {
      content: this.contentTarget,
      allowHTML: true,
      trigger: 'click',
      placement: 'bottom',
    })
  }
}
