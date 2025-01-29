/* eslint-disable no-console */
import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'
// import Dropzone from 'dropzone'

// Connects to data-controller="media-library-new"
export default class extends Controller {
  static targets = ['dropzone']

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
      files.forEach((file) => this.submitAction(file))
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
      Array.from(files).forEach((file) => {
        vm.submitAction(file)
      })
    }, false)
  }

  // uploadRequestDidProgress(event) {
  //   console.log('uploadRequestDidProgress', event)
  // }

  submitAction(file) {
    const upload = new DirectUpload(file, this.directUploadsUrlValue)
    // console.log('upload', upload, this.dropzoneTarget, this)
    // this.dropzoneTarget.addEventListener('direct-upload:progress', (id, file, progress) => {
    //   console.log('this.dropzoneTarget.progress', id, file, progress)
    // })

    upload.create((error, blob) => {
      if (error) {
        console.log('Error', error)
      }
    })
  }

  dragAction() {
    this.element.classList.add(...this.draggingClasses)
    this.element.innerHTML = this.dropCopy
  }

  dropAction() {
    this.element.classList.remove(...this.draggingClasses)
    this.element.innerHTML = this.droppedCopy
  }
}
