/* eslint-disable camelcase */
import '@github/markdown-toolbar-element'
import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'
import { post } from '@rails/request.js'

// upload code from Jeremy Smith's blog post
// https://hybrd.co/posts/github-issue-style-file-uploader-using-stimulus-and-active-storage

// Connects to data-controller="form"
export default class extends Controller {
  static values = {
    attachUrl: String,
    previewUrl: String,
    resourceClass: String,
    fieldId: String,
  }

  static targets = ['fieldElement', 'previewElement', 'writeTabButton', 'previewTabButton']

  switchToWrite(event) {
    event.preventDefault()

    // toggle buttons
    this.writeTabButtonTarget.classList.add('hidden')
    this.previewTabButtonTarget.classList.remove('hidden')

    // toggle write/preview buttons
    this.fieldElementTarget.classList.remove('hidden')
    this.previewElementTarget.classList.add('hidden')
  }

  switchToPreview(event) {
    event.preventDefault()

    post(this.previewUrlValue, {
      body: {
        body: this.fieldElementTarget.value,
        resource_class: this.resourceClassValue,
        field_id: this.fieldIdValue,
        element_id: this.previewElementTarget.id,
      },
      responseKind: 'turbo-stream',
    })

    // set the min height to the field element height
    this.previewElementTarget.style.minHeight = `${this.fieldElementTarget.offsetHeight}px`

    // toggle buttons
    this.writeTabButtonTarget.classList.remove('hidden')
    this.previewTabButtonTarget.classList.add('hidden')

    // toggle elements
    this.fieldElementTarget.classList.add('hidden')
    this.previewElementTarget.classList.remove('hidden')
  }

  dropUpload(event) {
    event.preventDefault()
    this.uploadFiles(event.dataTransfer.files)
  }

  pasteUpload(event) {
    if (!event.clipboardData.files.length) return

    event.preventDefault()
    this.uploadFiles(event.clipboardData.files)
  }

  uploadFiles(files) {
    Array.from(files).forEach((file) => this.uploadFile(file))
  }

  uploadFile(file) {
    const upload = new DirectUpload(file, this.attachUrlValue)

    upload.create((error, blob) => {
      if (error) {
        console.log('Error', error)
      } else {
        const text = this.markdownLink(blob)
        const start = this.fieldElementTarget.selectionStart
        const end = this.fieldElementTarget.selectionEnd
        this.fieldElementTarget.setRangeText(text, start, end)
      }
    })
  }

  markdownLink(blob) {
    const { filename } = blob
    const url = `/rails/active_storage/blobs/${blob.signed_id}/${filename}`
    const prefix = (this.isImage(blob.content_type) ? '!' : '')

    return `${prefix}[${filename}](${url})\n`
  }

  isImage(contentType) {
    return ['image/jpeg', 'image/gif', 'image/png'].includes(contentType)
  }
}
