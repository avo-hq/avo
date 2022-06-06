import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['svg', 'items', 'self'];

  collapsed = true;

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
    if (this.defaultState === 'collapsed') {
      return this.userState === 'collapsed'
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
    this.itemsTarget.classList.add('hidden')
  }

  markExpanded() {
    this.svgTarget.classList.remove('rotate-90')
    this.itemsTarget.classList.remove('hidden')
  }
}
