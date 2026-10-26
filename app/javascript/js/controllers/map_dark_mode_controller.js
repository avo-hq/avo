import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { styles: Object }

  connect() {
    // No styles pair means the resource passed its own `style:` through
    // `mapkick_options`. Avo doesn't retheme a map it didn't style.
    if (!this.hasStylesValue) return

    // Maps are always built with the light style; nothing has swapped it yet.
    this.appliedStyle = this.stylesValue.light

    this.observer = new MutationObserver(() => this.updateMapStyle())
    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    })

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
    const map = this.mapkickInstance?.map
    if (!map) return

    // `getStyle()` throws while a style is still loading, and a theme toggle
    // lands in that window often enough to matter. Wait the load out instead of
    // dropping the change — nothing else would come along to re-trigger it.
    if (!map.isStyleLoaded()) {
      map.once('idle', () => this.updateMapStyle())
      return
    }

    // A light and a dark style can be indistinguishable once loaded — OpenFreeMap's
    // pair shares a sprite URL and ships no name — so track what we applied rather
    // than sniffing it back off the map.
    const targetStyle = this.isDark ? this.stylesValue.dark : this.stylesValue.light
    if (targetStyle === this.appliedStyle) return

    // Save the sources and layers Mapkick added before the style swap wipes them
    const snapshot = this.captureMapkickState(map)

    this.appliedStyle = targetStyle
    // `diff: false` forces a full style reload. The default diffing path drops
    // Mapkick's sources and layers without ever firing `style.load`, so the
    // markers would vanish with nothing to restore them.
    map.setStyle(targetStyle, { diff: false })

    // Restore sources, layers, and marker images after the new style loads
    map.once('style.load', () => {
      this.restoreMapkickState(map, snapshot)
    })
  }

  captureMapkickState(map) {
    const style = map.getStyle()
    const sources = {}
    const layers = []
    const images = []

    // Mapkick's sources (markers, labels, trails) are the GeoJSON ones; whatever
    // else is in there belongs to the base map and comes back with the new style.
    for (const [name, source] of Object.entries(style.sources)) {
      if (source.type !== 'geojson') continue

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
