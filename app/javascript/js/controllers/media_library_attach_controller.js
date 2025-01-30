/* eslint-disable no-console */
// eslint-disable-next-line max-classes-per-file
import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'
import { escape } from 'lodash'

class UploadObject extends EventTarget {
  constructor(file, controller) {
    super()

    this.file = file
    this.controller = controller
    this.finished = false
  }

  hasFinished() {
    return this.finished
  }

  handle() {
    const upload = new DirectUpload(this.file, this.controller.directUploadsUrlValue, this)

    this.#addUploadingItem(this.file)

    upload.create((error, blob) => {
      if (error) {
        console.log('Error', error)
      }
      this.listItem.classList.add('text-gray-400')

      this.finished = true
      this.dispatchEvent(new Event('done'))
    })
  }

  #addUploadingItem(file) {
    const div = document.createElement('div')
    div.classList.add('flex', 'justify-between', 'gap-2', 'text-sm')
    div.innerHTML = `<div>${escape(file.name)}</div><div class="progress">0%</div>`
    this.listItem = this.controller.uploadingContainerTarget.appendChild(div)
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener(
      'progress',
      (event) => this.#directUploadDidProgress(event),
    )
  }

  #directUploadDidProgress(event) {
    const progress = (event.loaded / event.total) * 100
    const element = this.listItem.querySelector('.progress')
    element.textContent = `${progress.toFixed(2)}%`
  }
}

// Connects to data-controller="media-library-new"
export default class extends Controller {
  static targets = ['dropzone', 'uploadingContainer']

  static values = {
    directUploadsUrl: String,
  }

  dragCopy = 'drag file or click to upload'

  dropCopy = "drop it like it's hot"

  droppedCopy = 'uploading file. hang tight'

  unsupportedCopy = 'wrong file type. try again'

  draggingClasses = ['dropzone-dragging', '!border-gray-700', '!text-gray-700']

  connect() {
    this.attachHandlers()
    this.setupFileInput()
  }

  setupFileInput() {
    // Create a hidden file input element
    this.fileInput = document.createElement('input')
    this.fileInput.type = 'file'
    this.fileInput.multiple = true
    this.fileInput.style.display = 'none'
    this.element.appendChild(this.fileInput)

    // Handle file selection
    this.fileInput.addEventListener('change', (e) => {
      const files = Array.from(e.target.files)
      this.#submitFiles(files)
      this.fileInput.value = '' // Reset the input for future selections
    })
  }

  triggerFileBrowser() {
    this.fileInput.click()
  }

  attachHandlers() {
    const vm = this

    Array.from(['drag', 'dragstart', 'dragend', 'dragover', 'dragenter', 'dragleave', 'drop']).forEach((event) => {
      vm.dropzoneTarget.addEventListener(event, (e) => {
        e.preventDefault()
        e.stopPropagation()
      })
    })

    this.dropzoneTarget.addEventListener('dragover', (e) => {
      vm.dragAction()
    }, false)

    this.dropzoneTarget.addEventListener('dragleave', (e) => {
      vm.dropAction()
    }, false)

    this.dropzoneTarget.addEventListener('drop', (e) => {
      vm.dropAction()
      const { files } = e.dataTransfer
      this.#submitFiles(files)
    }, false)
  }

  #submitFiles(files) {
    this.uploadObjects = []
    Array.from(files).forEach((file) => {
      const uploadObject = new UploadObject(file, this)
      this.uploadObjects.push(uploadObject)
      uploadObject.addEventListener('done', () => {
        this.#checkIfAllFinished()
      })
      uploadObject.handle()
    })
  }

  #checkIfAllFinished() {
    if (this.uploadObjects.every((uploadObject) => uploadObject.hasFinished())) {
      this.#refreshPage()
    }
  }

  #refreshPage() {
    const streamElement = document.createElement('turbo-stream')
    streamElement.setAttribute('action', 'refresh')
    streamElement.setAttribute('method', 'morph')
    streamElement.setAttribute('render', 'morph')
    this.element.appendChild(streamElement)
  }

  dragAction() {
    this.dropzoneTarget.classList.add(...this.draggingClasses)
    this.dropzoneTarget.innerHTML = this.dropCopy
  }

  dropAction() {
    this.dropzoneTarget.classList.remove(...this.draggingClasses)
    this.dropzoneTarget.innerHTML = this.droppedCopy
  }
}
