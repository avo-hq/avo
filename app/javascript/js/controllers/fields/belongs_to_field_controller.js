import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['select', 'type']

  get selectedType() {
    return this.selectTarget.value
  }

  connect() {
    this.setValidNames()
    this.changedType()
  }

  setValidNames() {
    this.typeTargets.forEach((target) => {
      const { type } = target.dataset
      const select = target.querySelector('select')
      const name = select.getAttribute('name')

      select.setAttribute('valid-name', name)
      if (this.selectedType !== type) {
        select.selectedIndex = 0
      }
    })
  }

  changedType() {
    this.hideAllTypeTargets()
    this.enableType(this.selectTarget.value)
  }

  hideAllTypeTargets() {
    this.typeTargets.forEach((target) => {
      this.hideTarget(target)
      this.invalidateTarget(target)
    })
  }

  hideTarget(target) {
    target.classList.add('hidden')
  }

  invalidateTarget(target) {
    const select = target.querySelector('select')

    select.setAttribute('name', '')
  }

  validateTarget(target) {
    const select = target.querySelector('select')
    const validName = select.getAttribute('valid-name')

    select.setAttribute('name', validName)
  }

  enableType(type) {
    const target = this.typeTargets.find((typeTarget) => typeTarget.dataset.type === type)

    if (target) {
      target.classList.remove('hidden')
      this.validateTarget(target)
    }
  }
}
