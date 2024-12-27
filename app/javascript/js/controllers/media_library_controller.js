/* eslint-disable no-console */
import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="media-library"
export default class extends Controller {
  static outlets = ['field']

  static values = {
    itemDetailsFrameId: String,
    controllerSelector: String,
    controllerName: String,
  }

  selectItem(event) {
    const { params } = event
    const { attaching } = params
    // When attaching, we want to prevent showing the details screen and instead just check the attachment
    if (attaching) {
      event.preventDefault()
      // TODO: allow multiple attachments
      // get the controller for the selector and name
      const otherController = this.application.getControllerForElementAndIdentifier(document.querySelector(this.controllerSelectorValue), this.controllerNameValue)

      // show an error if the controller is not found
      if (!otherController) {
        console.error('[Avo->] The Media Library failed to find any field outlets to inject the asset.')

        return
      }
      // Trigger the insertAttachment action on the other controller
      otherController.insertAttachment(event)
    }
  }

  closeItemDetails() {
    document.querySelector(`turbo-frame#${this.itemDetailsFrameIdValue}`).innerHTML = ''
  }
}
