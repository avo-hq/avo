import { Controller } from '@hotwired/stimulus'
import { computePosition, flip, shift } from '@floating-ui/dom'

export default class extends Controller {
  static targets = ['resourceAction', 'standaloneAction', 'popover', 'button']

  static classes = ['enabled', 'disabled']

  target = {}

  get targetIsDisabled() {
    return this.target.dataset.disabled === 'true'
  }

  get actionsShowTurboFrame() {
    return document.querySelector(`turbo-frame#${window.Avo.configuration.modal_frame_id}`)
  }

  pop() {
    console.log('pop', this.popoverTarget, this.buttonTarget)
    // this.popoverTarget.togglePopover()

    // computePosition(this.buttonTarget, this.popoverTarget, {
    //   // Try changing this to a different side.
    //   placement: 'bottom-end',
    //   middleware: [flip(), shift()],
    // }).then(({ x, y }) => {
    //   console.log(x, y)
    //   Object.assign(this.popoverTarget.style, {
    //     top: `${y}px`,
    //     left: `${x}px`,
    //   })
    // })
  }

  enableTarget() {
    if (this.targetIsDisabled) {
      this.target.classList.remove(...this.disabledClasses)
      this.target.classList.add(...this.enabledClasses)
      this.target.dataset.disabled = false
    }
  }

  disableTarget() {
    this.target.classList.remove(...this.enabledClasses)
    this.target.classList.add(...this.disabledClasses)
    this.target.dataset.disabled = true
  }

  visitAction(event) {
    this.target = event.target

    if (this.targetIsDisabled) {
      event.preventDefault()

      return
    }

    this.disableTarget()
    const that = this
    setTimeout(() => {
      this.actionsShowTurboFrame.loaded.then(() => that.enableTarget(that.target))
    }, 1)
  }
}
