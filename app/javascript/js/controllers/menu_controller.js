import { Controller } from '@hotwired/stimulus'
import { enter, leave } from 'el-transition'

export default class extends Controller {
  static targets = ['svg', 'items', 'self']

  collapsed = true

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
      this.markCollapsed(true)
    } else {
      this.markExpanded(true)
    }
  }

  markCollapsed(animate = false) {
    this.svgTarget.classList.add('rotate-90')
    if (animate) {
      leave(this.itemsTarget)
    } else {
      this.itemsTarget.classList.add('hidden')
    }
  }

  markExpanded(animate = false) {
    this.svgTarget.classList.remove('rotate-90')
    if (animate) {
      enter(this.itemsTarget)
    } else {
      this.itemsTarget.classList.remove('hidden')
    }
  }
}
