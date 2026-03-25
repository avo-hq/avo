import { Controller } from "@hotwired/stimulus"

const TYPING_SELECTOR = "input, textarea, select, [contenteditable]"

export default class extends Controller {
  connect() {
    this.currentIndex = -1
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    if (event.defaultPrevented || event.repeat) return
    if (event.target.closest(TYPING_SELECTOR)) return
    if (!["ArrowDown", "ArrowUp", "Enter", "Escape"].includes(event.key)) return

    const rows = Array.from(this.element.querySelectorAll("tr[data-visit-path]"))
    if (!rows.length) return

    if (event.key === "Escape") {
      if (this.currentIndex === -1) return
      event.preventDefault()
      this.clearFocus(rows)
      return
    }

    if (event.key === "Enter") {
      if (this.currentIndex === -1) return
      event.preventDefault()
      const row = rows[this.currentIndex]
      if (row?.dataset.visitPath) window.Turbo.visit(row.dataset.visitPath)
      return
    }

    // ArrowDown / ArrowUp
    event.preventDefault()
    if (event.key === "ArrowDown") {
      this.currentIndex = this.currentIndex < rows.length - 1 ? this.currentIndex + 1 : 0
    } else {
      this.currentIndex = this.currentIndex > 0 ? this.currentIndex - 1 : rows.length - 1
    }

    rows.forEach((r, i) => r.classList.toggle("is-keyboard-focused", i === this.currentIndex))
    rows[this.currentIndex].scrollIntoView({ block: "nearest", inline: "nearest" })
  }

  clearFocus(rows) {
    rows.forEach(r => r.classList.remove("is-keyboard-focused"))
    this.currentIndex = -1
  }
}
