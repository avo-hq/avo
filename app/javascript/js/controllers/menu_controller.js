import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['svg', 'items', 'self']

  collapsed = true

  transitionClass = 'css-animate-slide-down'

  get key() {
    return this.selfTarget.getAttribute('data-menu-key-param')
  }

  get defaultState() {
    return this.selfTarget.getAttribute('data-menu-default-collapsed-state')
  }

  get userState() {
    return window.localStorage.getItem(this.key)
  }

  set userState(payload) {
    window.localStorage.setItem(this.key, payload)
  }

  get initiallyCollapsed() {
    if (!this.userState) {
      return this.defaultState === 'collapsed'
    }

    return this.userState === 'collapsed'
  }

  connect() {
    if (this.initiallyCollapsed) {
      this.collapsed = true
      this.markCollapsed()
    } else {
      this.collapsed = false
      this.markExpanded()
    }
  }

  triggerCollapse() {
    this.collapsed = !this.collapsed
    this.userState = this.collapsed ? 'collapsed' : 'expanded'

    this.updateDom()
  }

  updateDom() {
    if (this.collapsed) {
      this.markCollapsed()
    } else {
      this.markExpanded()
    }
  }

  markCollapsed() {
    this.svgTarget.classList.add('rotate-90')
    this.leave(this.itemsTarget)
  }

  markExpanded() {
    this.svgTarget.classList.remove('rotate-90')
    this.enter(this.itemsTarget)
  }

  toggle(element) {
    element.toggleAttribute('hidden')
  }

  async leave(element) {
    element.setAttribute('hidden', true)
    await this.animateTransition(element)
  }

  async enter(element) {
    element.removeAttribute('hidden')
    await this.animateTransition(element)
  }

  async animateTransition(element) {
    element.classList.add(this.transitionClass)
    await this.onTransitionsEnded(element)
    element.classList.remove(this.transitionClass)
  }

  onTransitionsEnded(node) {
    return Promise.allSettled(
      node.getAnimations().map((animation) => animation.finished),
    )
  }
}
