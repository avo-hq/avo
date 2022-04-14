import { Controller } from '@hotwired/stimulus'
import isNull from 'lodash/isNull'

export default class extends Controller {
  static targets = ['svg', 'items', 'self'];

  collapsed = false;

  get key() {
    return this.selfTarget.getAttribute('data-menu-key-param')
  }

  defaultState() {
    return this.selfTarget.getAttribute('data-menu-collapsed-param') === 'collapsed'
  }

  connect() {
    if (this.getState() === 'collapsed') {
      this.collapsed = true
      this.markCollapsed()
    } else if (isNull(this.getState()) && this.defaultState()) {
      this.collapsed = true
      this.markCollapsed()
    }
  }

  triggerCollapse() {
    this.collapsed = !this.collapsed

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
    this.storeState('collapsed')
  }

  markExpanded() {
    this.svgTarget.classList.remove('rotate-90')
    this.itemsTarget.classList.remove('hidden')
    this.storeState('expanded')
  }

  getState() {
    return window.localStorage.getItem(this.key)
  }

  storeState(payload) {
    window.localStorage.setItem(this.key, payload)
  }
}
