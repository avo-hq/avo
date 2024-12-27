/* eslint-disable camelcase */
/* eslint-disable no-alert */
import 'trix'
import { post } from '@rails/request.js'
import URI from 'urijs'

import { Controller } from '@hotwired/stimulus'

// eslint-disable-next-line max-len
const galleryButtonSVG = '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 0 0 1.5-1.5V6a1.5 1.5 0 0 0-1.5-1.5H3.75A1.5 1.5 0 0 0 2.25 6v12a1.5 1.5 0 0 0 1.5 1.5Zm10.5-11.25h.008v.008h-.008V8.25Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z" /></svg>'

export default class extends Controller {
  static targets = ['editor', 'controller']

  static values = {
    resourceName: String,
    resourceId: String,
    attachmentsDisabled: Boolean,
    attachmentKey: String,
    hideAttachmentFilename: Boolean,
    hideAttachmentFilesize: Boolean,
    hideAttachmentUrl: Boolean,
    isActionText: Boolean,
    uploadWarning: String,
    attachmentDisableWarning: String,
    attachmentKeyWarning: String,
  }

  get rootPath() {
    return new URI(window.Avo.configuration.root_path)
  }

  get uploadUrl() {
    // Parse the current URL
    const url = new URI(window.location.origin)
    // Build the trix field path
    url.path(`${this.rootPath.path()}/avo_api/resources/${this.resourceNameValue}/${this.resourceIdValue}/attachments`)
    // Add the params back
    url.query(this.rootPath.query())

    return url.toString()
  }

  connect() {
    this.#attachTrixListeners()
  }

  disconnect() {
    this.#removeTrixListeners()
  }

  // Invoked by the other controllers (media-library)
  insertAttachment(event) {
    const { params } = event
    const { path, blob } = params

    const payload = {
      url: path,
      filename: blob.filename,
      contentType: blob.content_type,
      previewable: true,
    }

    const model = new window.Trix.models.Attachment(payload)
    this.editorTarget.editorController.editor.insertAttachment(model)
  }

  #removeTrixListeners() {
    this.element.removeEventListener('trix-file-accept', this.#trixFileAccept.bind(this))
    this.element.removeEventListener('trix-attachment-add', this.#trixAttachmentAdd.bind(this))
    this.element.removeEventListener('trix-initialize', this.#trixInitialize.bind(this))
  }

  #attachTrixListeners() {
    this.element.addEventListener('trix-file-accept', this.#trixFileAccept.bind(this))
    this.element.addEventListener('trix-attachment-add', this.#trixAttachmentAdd.bind(this))
    this.element.addEventListener('trix-initialize', this.#trixInitialize.bind(this))
  }

  #trixInitialize(event) {
    // Remove the attachments button from the toolbar if the field has attachments disabled
    if (this.attachmentsDisabledValue) {
      if (event.target === this.editorTarget) {
        this.controllerTarget.querySelector('.trix-button-group--file-tools').remove()
      }
    }

    // Add the gallerybutton to the toolbar
    const buttonHTML = `<button type="button" data-trix-action="gallery" class="trix-button trix-button--icon">${galleryButtonSVG}</button>`
    event.target.toolbarElement
      .querySelector('.trix-button-group--file-tools')
      .insertAdjacentHTML('beforeend', buttonHTML)

    // vm is the controller instance
    const vm = this
    const gallery = {
      test() {
        return true
      },
      perform() {
        // this is the trix instance
        // we need to set the outlet_selector to the unique_id of the trix field controller based on `this`
        // `this` will probide the context at runtime, when the action is called, not when tris is initially set.
        // we send that to the servr so the media library controller knows which field is being used to delegate the attach event
        const controllerElement = this.editor.element.closest('[data-trix-field-target="controller"]')
        post(`${vm.rootPath.path()}/media_library`, {
          query: {
            resource_name: vm.resourceNameValue,
            record_id: vm.resourceIdValue,
            controller_selector: controllerElement.dataset.trixFieldUniqueSelectorValue,
            controller_name: vm.identifier,
          },
          responseKind: 'turbo-stream',
        })
      },
    }
    // Add the gallery action to the editor
    Object.assign(this.editorTarget.editorController.actions, { gallery })
  }

  #trixAttachmentAdd(event) {
    if (event.target === this.editorTarget) {
      if (event.attachment.file) {
        this.uploadFileAttachment(event.attachment)
      }
    }
  }

  #trixFileAccept(event) {
    if (event.target === this.editorTarget) {
      // Prevent file uploads for fields that have attachments disabled.
      if (this.attachmentsDisabledValue) {
        event.preventDefault()
        alert(this.attachmentDisableWarningValue)

        return
      }

      // Prevent file uploads for resources that haven't been saved yet.
      if (!this.resourceIdValue) {
        event.preventDefault()
        alert(this.uploadWarningValue)

        return
      }

      // Prevent file uploads for fields without an attachment key.
      // When is rich text, attachment key is not needed.
      if (!this.isActionTextValue && !this.attachmentKeyValue) {
        event.preventDefault()
        alert(this.attachmentKeyWarningValue)
      }
    }
  }

  uploadFileAttachment(attachment) {
    this.uploadFile(
      attachment.file,
      (progress) => attachment.setUploadProgress(progress),
      (attributes) => attachment.setAttributes(attributes),
    )
  }

  uploadFile(file, progressCallback, successCallback) {
    const formData = this.createFormData(file)
    const xhr = new XMLHttpRequest()

    xhr.open('POST', this.uploadUrl, true)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      xhr.setRequestHeader('X-CSRF-Token', csrfToken)
    }

    xhr.upload.addEventListener('progress', (event) => {
      // eslint-disable-next-line no-mixed-operators
      const progress = event.loaded / event.total * 100
      progressCallback(progress)
    })

    xhr.addEventListener('load', () => {
      if (xhr.status === 200) {
        let response
        try {
          response = JSON.parse(xhr.response)
        } catch (error) {
          response = {}
        }

        const attributes = {
          url: response.url,
          href: response.href,
        }

        if (this.hideAttachmentFilenameValue) attributes.filename = null
        if (this.hideAttachmentFilesizeValue) attributes.filesize = null
        if (this.hideAttachmentUrlValue) attributes.href = null

        successCallback(attributes)
      }
    })

    xhr.send(formData)
  }

  createStorageKey(file) {
    const date = new Date()
    const day = date.toISOString().slice(0, 10)
    const name = `${date.getTime()}-${file.name}`

    return ['tmp', day, name].join('/')
  }

  createFormData(file) {
    const data = new FormData()
    data.append('Content-Type', file.type)
    data.append('file', file)
    data.append('filename', file.name)
    if (!this.attachmentKeyValue) {
      data.append('key', this.createStorageKey(file))
    } else {
      data.append('attachment_key', this.attachmentKeyValue)
    }

    return data
  }
}
