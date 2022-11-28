/* eslint-disable no-alert */
import 'trix'
import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['editor', 'controller']

  get resourceId() {
    return this.controllerTarget.dataset.resourceId
  }

  get resourceName() {
    return this.controllerTarget.dataset.resourceName
  }

  get attachmentKey() {
    return this.controllerTarget.dataset.attachmentKey
  }

  get attachmentsDisabled() {
    return castBoolean(this.controllerTarget.dataset.attachmentsDisabled)
  }

  get hideAttachmentFilename() {
    return castBoolean(this.controllerTarget.dataset.hideAttachmentFilename)
  }

  get hideAttachmentFilesize() {
    return castBoolean(this.controllerTarget.dataset.hideAttachmentFilesize)
  }

  get hideAttachmentUrl() {
    return castBoolean(this.controllerTarget.dataset.hideAttachmentUrl)
  }

  get uploadUrl() {
    return `${window.location.origin}${window.Avo.configuration.root_path}/avo_api/resources/${this.resourceName}/${this.resourceId}/attachments`
  }

  connect() {
    if (this.attachmentsDisabled) {
      // Remove the attachments button
      this.controllerTarget.querySelector('.trix-button-group--file-tools').remove()
    }

    window.addEventListener('trix-file-accept', (event) => {
      if (event.target === this.editorTarget) {
        // Prevent file uploads for fields that have attachments disabled.
        if (this.attachmentsDisabled) {
          event.preventDefault()
          alert('This field has attachments disabled.')

          return
        }

        // Prevent file uploads for resources that haven't been saved yet.
        if (this.resourceId === '') {
          event.preventDefault()
          alert("You can't upload files into the Trix editor until you save the resource.")

          return
        }

        // Prevent file uploads for fields without an attachment key.
        if (this.attachmentKey === '') {
          event.preventDefault()
          alert("You haven't set an `attachment_key` to this Trix field.")
        }
      }
    })

    window.addEventListener('trix-attachment-add', (event) => {
      if (event.target === this.editorTarget) {
        if (event.attachment.file) {
          this.uploadFileAttachment(event.attachment)
        }
      }
    })
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

        if (this.hideAttachmentFilename) attributes.filename = null
        if (this.hideAttachmentFilesize) attributes.filesize = null
        if (this.hideAttachmentUrl) attributes.href = null

        successCallback(attributes)
      }
    })

    xhr.send(formData)
  }

  createFormData(file) {
    const data = new FormData()
    data.append('Content-Type', file.type)
    data.append('file', file)
    data.append('filename', file.name)
    data.append('attachment_key', this.attachmentKey)

    return data
  }
}
