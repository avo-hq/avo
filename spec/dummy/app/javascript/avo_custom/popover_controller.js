import Popover from 'stimulus-popover'
import { get } from '@rails/request.js'

export default class extends Popover {
  static targets = ['card', 'content', 'container']

  static values = {
    url: String,
    turboFrame: String
  }

  get cardTarget() {
    document.querySelector('turbo-frame[src=""]')
  }

  connect() {
    super.connect()
    console.log('popover_controller')
    // console.log(this.elementTarget)
  }

  async Xfetch () {
    if (!this.remoteContent) {
      if (!this.hasUrlValue) {
        console.error('[stimulus-popover] You need to pass an url to fetch the popover content.')
        return
      }


      console.log('this.urlValue->', this.urlValue)

      await get(this.urlValue, {
        // body: {
        //   index: index
        // },
        // contentType: "application/json",
        responseKind: "turbo-stream",
        responseKind: "html"
      })

      // const response = await fetch(this.urlValue)
      // this.remoteContent = await response.text()
    }

    return this.remoteContent
  }

  async show (event) {
    // Temporally variable to prevent `event.currentTarget` to being null.
    const element = event.currentTarget

    let content = null

    if (this.hasContentTarget) {
      content = this.contentTarget.innerHTML
    } else {
      content = await this.fetch()
    }

    if (!content) return

    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = content
    }

    // const fragment = document.createRange().createContextualFragment(content)
    // @ts-ignore
    // element.appendChild(fragment)
  }

  hide () {
    // console.log('this.remoteContent->', this.remoteContent)
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = ""
    }
    // if (this.hasCardTarget) {
    //   this.remoteContent.remove()
    // }
  }
}
