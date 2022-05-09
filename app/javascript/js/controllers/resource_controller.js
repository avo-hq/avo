/* eslint-disable camelcase */
import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'
// import { reloadPage } from '../page_reloader'

export default class extends Controller {
  // static targets = ['element']
  static values = {
    resourceName: String,
    resourceId: String,
    view: String,
    channelName: String,
  }

  get consumer() {
    return window.Avo.consumer
  }

  connect() {
    console.log('resource_controller', this.context.element, this.resourceNameValue, this.consumer, this.viewValue)
    if (this.consumer) {
      this.listen()
    }
  }

  listen() {
    const vm = this
    this.consumer.subscriptions.create(
      {
        channel: this.channelNameValue,
        resource_name: this.resourceNameValue,
        resource_id: this.resourceIdValue,
      },
      {
        received(data) {
          // console.log('received->', data)
          const { action } = data
          if (action === 'reload') {
            console.log('reloadingg->', this)
            vm.reloadPage()
          }
        // this.appendLine(data)
        },
      },
    )
    // this.consumer.subscriptions.create(
    //   {
    //     channel: 'AvoChannel',
    //     resource_name: this.resourceNameValue,
    //     resource_id: this.resourceIdValue,
    //   },
    //   {
    //     received(data) {
    //       console.log('received->', data)
    //       const { action } = data
    //       if (action === 'reload') {
    //         console.log('reloadingg->')
    //       }
    //     // this.appendLine(data)
    //     },
    //   },
    // )
  }

  // We can't wrap the resource show component in a turbo frame because it will hijack the links inside to only feel this frame
  // So we try to trick it.
  // We'll create a turbo-frame element with this url as the src.
  // This will trigger a reload and the record will be refreshed.
  // In the last step we'll reverse the process.
  reloadPage() {
    // create a new turbo-frame element
    const frame = this.element.parentElement

    const frameId = 'resource_show'

    const src = URI(window.location.href).search({ turbo_frame: frameId })
    const frameSrc = src.toString()

    frame.id = frameId
    frame.src = frameSrc
    // frame.src = 'window.location.href?#{}'
    // console.log('this->', src, src.toString())

    // add an empty element inside
    const span = document.createElement('span')

    // add the empty element in the frame
    frame.appendChild(span)

    // add the frame before the resource show component
    this.element.parentElement.insertBefore(frame, this.element)

    // replace the dummy element with the contents of the component
    span.replaceWith(this.element)

    // revert the changes and remove the turbo-frame

    function frameRenderCallback(e) {
      console.log('e->', e, e.srcElement.id, e.srcElement.src)
      if (e.srcElement.id === frameId && e.srcElement.src === frameSrc) {
        console.log('it is')
        frame.parentElement.insertBefore(frame, this.element)
      }
      document.removeEventListener('turbo:frame-render', frameRenderCallback)
    }
    document.addEventListener('turbo:frame-render', frameRenderCallback)
    // frame.remove()

    // console.log('this.element->', this.element, frame)
  }
}
