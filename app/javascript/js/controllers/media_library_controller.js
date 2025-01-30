/* eslint-disable no-console */
import { Controller } from '@hotwired/stimulus'
import { closeModal } from '../helpers'

// Connects to data-controller="media-library"
export default class extends Controller {
  static outlets = ['field']

  static values = {
    itemDetailsFrameId: String,
    controllerSelector: String,
    controllerName: String,
    selectedItems: Array,
  }

  // get the controller for the selector and name
  get otherController() {
    return this.application.getControllerForElementAndIdentifier(document.querySelector(this.controllerSelectorValue), this.controllerNameValue)
  }

  // get the controller for the selector and name
  get modalController() {
    return this.application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="modal"]'), 'modal')
  }

  // selectItems(event) {
  //   // Search the DOM for the media library list component
  //   const mediaLibraryList = document.querySelector('[data-controller="media-library"]')

  //   // Get the elements that have the data-selected attribute set to true
  //   const selectedItems = mediaLibraryList.querySelectorAll('[data-selected="true"]')

  //   // get the attachment and blob information from the selected items
  //   const attachments = Array.from(selectedItems).map((item) => {
  //     const attachment = JSON.parse(item.dataset.mediaLibraryAttachmentParam)
  //     const blob = JSON.parse(item.dataset.mediaLibraryBlobParam)
  //     const path = item.dataset.mediaLibraryPathParam

  //     return { attachment, blob, path }
  //   })

  //   this.insertAttachments(attachments, event)
  //   this.modalController.closeModal()
  // }

  selectItem(event) {
    const { params } = event
    const { attaching, multiple } = params
    const item = event.target.closest('[data-component="avo/media_library/list_item_component"]')
    const attachments = [this.#extractMetadataFromItem(item)]
    // When attaching, we want to prevent showing the details screen and instead just check the attachment
    if (attaching) {
      event.preventDefault()
      this.insertAttachments(attachments, event)
      closeModal()

      // TODO: allow multiple attachments
      // if (multiple) {
      //   const element = document.querySelector(`[data-attachment-id="${params.attachment.id}"]`)
      //   element.dataset.selected = !(element.dataset.selected === 'true')
      // } else {
      //   this.insertAttachments(attachments, event)
      // }
    }
  }

  insertAttachments(attachments, event) {
    // show an error if the controller is not found
    if (!this.otherController) {
      console.error('[Avo->] The Media Library failed to find any field outlets to inject the asset.')

      return
    }
    // Trigger the insertAttachment action on the other controller
    this.otherController.insertAttachments(attachments, event)
  }

  closeItemDetails() {
    document.querySelector(`turbo-frame#${this.itemDetailsFrameIdValue}`).innerHTML = ''
  }

  #extractMetadataFromItem(item) {
    const blob = JSON.parse(item.dataset.mediaLibraryBlobParam)
    const path = item.dataset.mediaLibraryPathParam

    return { blob, path }
  }
}
