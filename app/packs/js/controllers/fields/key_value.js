import { Controller } from 'stimulus'

export default class extends Controller {
  // static targets = ['element']

  connect() {
    console.log('key_value')
  }

  addRow() {
    console.log('addRow')
  }
}
