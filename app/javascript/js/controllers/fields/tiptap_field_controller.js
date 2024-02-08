import { Controller } from '@hotwired/stimulus'
import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'

export default class extends Controller {
  static targets = ['editor', 'controller', 'input']

  connect() {
    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        StarterKit,
      ],
      onUpdate: this.onUpdate,
      content: this.inputTarget.value
    })
  }

  onUpdate = () => {
    this.inputTarget.value = this.editor.getHTML()
  }
}
