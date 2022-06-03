import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    console.log('Dummy custom controller connected')
  }
}
