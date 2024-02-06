import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  refresh() {
    var element = this.context.scope.element.closest('turbo-frame');
    if (element) {
      element.reload();
    } else {
      console.error(
        "Element with ID '" + this.turboFrameIdValue + "' not found."
      );
    }
  }
}
