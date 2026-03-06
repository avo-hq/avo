import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['loader']

  connect() {
    this.observer = new MutationObserver(() => this.updateMapStyle())
    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    })

    this.waitForMap().then(() => {
      this.updateMapStyle()
      this.hideLoader()
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  showLoader() {
    if (this.hasLoaderTarget) {
      this.loaderTarget.removeAttribute('hidden')
    }
  }

  hideLoader() {
    if (this.hasLoaderTarget) {
      this.loaderTarget.setAttribute('hidden', '')
    }
  }

  waitForMap() {
    return new Promise((resolve) => {
      const check = () => {
        const instance = this.mapkickInstance
        if (instance?.map) {
          const map = instance.map
          if (map.loaded()) {
            resolve()
          } else {
            map.once('load', () => resolve())
          }
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
    const style = map.getStyle()
    if (!style) return

    const targetStyle = this.isDark
      ? 'mapbox://styles/mapbox/dark-v11'
      : 'mapbox://styles/mapbox/light-v11'

    // Detect current style from the sprite URL or stylesheet name
    const styleName = style.name || style.sprite || ''
    const currentIsDark = /dark/i.test(styleName)
    if (this.isDark === currentIsDark) return

    this.showLoader()

    // Save custom sources and layers added by Mapkick before the style swap
    const snapshot = this.captureMapkickState(map)

    map.setStyle(targetStyle)

    // Restore sources, layers, and marker images after the new style loads
    map.once('style.load', () => {
      this.restoreMapkickState(map, snapshot)
      this.hideLoader()
    })
  }

  captureMapkickState(map) {
    const style = map.getStyle()
    const sources = {}
    const layers = []
    const images = []

    // Capture Mapkick's custom sources (e.g. "objects", "trails", labels)
    for (const [name, source] of Object.entries(style.sources)) {
      // Skip Mapbox's built-in sources (composite, mapbox-)
      if (name === 'composite' || name.startsWith('mapbox')) continue

      sources[name] = {
        type: source.type,
        data: source.data,
      }
    }

    // Capture layers that reference our custom sources
    for (const layer of style.layers) {
      if (layer.source && sources[layer.source]) {
        layers.push(layer)
      }
    }

    // Capture marker images (mapkick-{id}-15 pattern)
    for (const id of Object.keys(map.style?.imageManager?.images || {})) {
      if (id.startsWith('mapkick-')) {
        const image = map.style.imageManager.images[id]
        if (image) {
          images.push({ id, data: image.data, pixelRatio: image.pixelRatio || 1 })
        }
      }
    }

    return { sources, layers, images }
  }

  restoreMapkickState(map, snapshot) {
    // Re-add marker images
    for (const img of snapshot.images) {
      if (!map.hasImage(img.id)) {
        map.addImage(img.id, img.data, { pixelRatio: img.pixelRatio })
      }
    }

    // Re-add sources
    for (const [name, config] of Object.entries(snapshot.sources)) {
      if (!map.getSource(name)) {
        map.addSource(name, config)
      }
    }

    // Re-add layers in original order
    for (const layer of snapshot.layers) {
      if (!map.getLayer(layer.id)) {
        map.addLayer(layer)
      }
    }
  }
}
