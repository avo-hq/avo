import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => this.updateMapStyle())
    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    })

    // Wait for Mapkick to initialize the map, then apply correct initial style
    this.waitForMap().then(() => this.updateMapStyle())
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  waitForMap() {
    return new Promise((resolve) => {
      const check = () => {
        if (this.mapkickInstance?.map) {
          resolve()
        } else {
          requestAnimationFrame(check)
        }
      }
      check()
    })
  }

  get mapkickInstance() {
    const mapDiv = this.element.querySelector('[id^="map-"]') || this.element.querySelector('[id]')
    if (!mapDiv?.id) return null

    return window.Mapkick?.maps?.[mapDiv.id]
  }

  get isDark() {
    return document.documentElement.classList.contains('dark')
  }

  updateMapStyle() {
    const instance = this.mapkickInstance
    if (!instance?.map) return

    const map = instance.map
    const currentStyle = map.getStyle()?.sprite
    const targetStyle = this.isDark
      ? 'mapbox://styles/mapbox/dark-v11'
      : 'mapbox://styles/mapbox/light-v11'

    // Don't re-apply the same style
    const isDarkStyle = currentStyle?.includes('dark')
    if (this.isDark === isDarkStyle) return

    map.setStyle(targetStyle, { diff: false })
  }
}
