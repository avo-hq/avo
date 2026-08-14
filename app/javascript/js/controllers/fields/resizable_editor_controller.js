import { Controller } from '@hotwired/stimulus'

const PERSIST_DELAY = 150

export default class extends Controller {
  static values = {
    targetSelector: String,
    storageKey: String,
  }

  connect() {
    this.persistTimer = null
    this.pendingHeight = null
    this.viewport = null

    this.mountViewport = this.mountViewport.bind(this)
    this.handleResize = this.handleResize.bind(this)
    this.flush = this.flush.bind(this)

    this.mutationObserver = new MutationObserver(this.mountViewport)
    this.mutationObserver.observe(this.element, { childList: true, subtree: true })

    window.addEventListener('pointerup', this.flush)
    document.addEventListener('turbo:before-cache', this.flush)

    this.mountViewport()
  }

  disconnect() {
    this.flush()
    this.mutationObserver?.disconnect()
    this.resizeObserver?.disconnect()

    window.removeEventListener('pointerup', this.flush)
    document.removeEventListener('turbo:before-cache', this.flush)
  }

  mountViewport() {
    const viewport = this.element.querySelector(this.targetSelectorValue)
    if (viewport === this.viewport) return

    this.resizeObserver?.disconnect()
    this.viewport = viewport
    if (!this.viewport) return

    this.viewport.classList.add('resizable-editor__viewport')
    this.restoreHeight()
    this.lastHeight = this.viewportHeight

    this.resizeObserver = new ResizeObserver(this.handleResize)
    this.resizeObserver.observe(this.viewport)
  }

  handleResize() {
    const height = this.viewportHeight
    if (!height || height === this.lastHeight) return

    this.lastHeight = height
    this.pendingHeight = height

    clearTimeout(this.persistTimer)
    this.persistTimer = setTimeout(this.flush, PERSIST_DELAY)
  }

  restoreHeight() {
    const value = window.Avo.localStorage.get(this.localStorageKey)
    if (!/^\d+$/.test(value || '')) return

    const height = Number(value)
    if (!Number.isSafeInteger(height) || height <= 0) return

    this.viewport.style.height = `${height}px`
  }

  flush() {
    clearTimeout(this.persistTimer)
    this.persistTimer = null

    if (!this.pendingHeight) return

    window.Avo.localStorage.set(this.localStorageKey, String(this.pendingHeight))
    this.pendingHeight = null
  }

  get viewportHeight() {
    return Math.round(this.viewport?.getBoundingClientRect().height || 0)
  }

  get localStorageKey() {
    const rootPath = window.Avo.configuration.root_path || '/'

    return `resizableEditors.v1.${encodeURIComponent(rootPath)}.${this.storageKeyValue}`
  }
}
