import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  copy() {
    const str = this.context.element.dataset.text
    /* ——— Derived from: https://hackernoon.com/copying-text-to-clipboard-with-javascript-df4d4988697f
          improved to add iOS device compatibility——— */
    const el = document.createElement('textarea') // Create a <textarea> element

    const storeContentEditable = el.contentEditable
    const storeReadOnly = el.readOnly

    el.value = str // Set its value to the string that you want copied
    el.contentEditable = true
    el.readOnly = false
    el.setAttribute('readonly', false) // Make it readonly false for iOS compatability
    el.setAttribute('contenteditable', true) // Make it editable for iOS
    el.style.position = 'absolute'
    el.style.left = '-9999px' // Move outside the screen to make it invisible
    document.body.appendChild(el) // Append the <textarea> element to the HTML document
    const selected = document.getSelection().rangeCount > 0 // Check if there is any content selected previously
      ? document.getSelection().getRangeAt(0) // Store selection if found
      : false // Mark as false to know no selection existed before
    el.select() // Select the <textarea> content
    el.setSelectionRange(0, 999999)
    document.execCommand('copy') // Copy - only works as a result of a user action (e.g. click events)
    document.body.removeChild(el) // Remove the <textarea> element
    if (selected) {
      // If a selection existed before copying
      document.getSelection().removeAllRanges() // Unselect everything on the HTML document
      document.getSelection().addRange(selected) // Restore the original selection
    }

    el.contentEditable = storeContentEditable
    el.readOnly = storeReadOnly
  }
}
