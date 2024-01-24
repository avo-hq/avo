import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    turboFrameId: String,
  };

  refresh() {
    var element = document.getElementById(this.turboFrameIdValue);
    if (element) {
      element.reload();
    } else {
      console.error(
        "Element with ID '" + this.turboFrameIdValue + "' not found."
      );
    }
  }
}
