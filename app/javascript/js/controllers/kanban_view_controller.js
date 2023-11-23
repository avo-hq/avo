import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs'
import { put } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "column" ]
  static values = {
    group: String
  }

  connect() {
    this.setupSortable()
    // console.log(this.columnTargets)
  }

  setupSortable() {
    this.columnTargets.forEach((column) => {
      new Sortable(column, {
        animation: 150,
        group: "kanban",
        onEnd: this.onEnd.bind(this)
      })
    })
  }

  onEnd(event) {
    const {from, to, oldIndex, newIndex, clone} = event
    console.log({from, to, oldIndex, newIndex, clone})

    put(clone.dataset.url, {
      responseKind: "turbo-stream",
      body: {
        kanban_column_id: to.dataset.recordId,
        position: newIndex + 1
      }
    })
  }
}

