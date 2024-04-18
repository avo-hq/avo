/* eslint-disable no-alert */
import 'trix'
import URI from 'urijs'

import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../../helpers/cast_boolean'

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
  }

  get uploadUrl() {
    // Parse the current URL
    const url = new URI(window.location.origin)
    // Parse the root path
    const rootPath = new URI(window.Avo.configuration.root_path)
    // Build the trix field path
    url.path(`${rootPath.path()}/avo_api/resources/${this.resourceNameValue}/${this.resourceIdValue}/attachments`)
    // Add the params back
    url.query(rootPath.query())

    return url.toString()
  }

  connect() {
    if (this.attachmentsDisabledValue) {
      // Remove the attachments button
      this.controllerTarget.querySelector('.trix-button-group--file-tools').remove()
    }

    window.addEventListener('trix-file-accept', (event) => {
      if (event.target === this.editorTarget) {
        // Prevent file uploads for fields that have attachments disabled.
        if (this.attachmentsDisabledValue) {
          event.preventDefault()
          alert('This field has attachments disabled.')

          return
        }

        // Prevent file uploads for resources that haven't been saved yet.
        if (!this.resourceIdValue) {
          event.preventDefault()
          alert("You can't upload files into the Trix editor until you save the resource.")

          return
        }

        // Prevent file uploads for fields without an attachment key.
        // When is rich text, attachment key is not needed.
        if (!this.isActionTextValue && !this.attachmentKeyValue) {
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
