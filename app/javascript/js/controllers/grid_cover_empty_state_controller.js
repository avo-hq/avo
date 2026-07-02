import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="grid-cover-empty-state"
export default class extends Controller {
  static targets = ['icon']

  mousemove(event) {
    const maxDist = 90
    const maxPush = 30
    const cursorX = event.clientX
    const cursorY = event.clientY

    this.iconTargets.forEach((icon) => {
      const r = icon.getBoundingClientRect()
      const cx = r.left + r.width / 2
      const cy = r.top + r.height / 2
      const dx = cx - cursorX
      const dy = cy - cursorY
      const dist = Math.sqrt(dx * dx + dy * dy)

      if (dist < maxDist && dist > 0) {
        const scale = parseFloat(icon.dataset.repulsionScale ?? 1)
        const force = (1 - dist / maxDist) * maxPush * scale
        icon.style.setProperty('--tx', `${(dx / dist) * force}px`)
        icon.style.setProperty('--ty', `${(dy / dist) * force}px`)
        icon.classList.add('grid-card__icon--repelling')
      } else {
        icon.style.setProperty('--tx', '0px')
        icon.style.setProperty('--ty', '0px')
        icon.classList.remove('grid-card__icon--repelling')
      }
    })
  }

  mouseleave() {
    this.iconTargets.forEach((icon) => {
      icon.style.setProperty('--tx', '0px')
      icon.style.setProperty('--ty', '0px')
      icon.classList.remove('grid-card__icon--repelling')
    })
  }
}
