import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="media-library"
export default class extends Controller {
  // static values = {
  //   attachment: Object,
  // }

  selectItem(event) {
    const { params } = event
    const { attachment, blob } = params
    console.log('selected2', event, attachment, blob)
  }

  closeItemDetails(event) {
    document.querySelector('turbo-frame#media_library_item_details').innerHTML = ''
  }

  connect() {
    console.log('connected')
  }
}
