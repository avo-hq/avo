import { Controller } from '@hotwired/stimulus'
import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import Underline from '@tiptap/extension-underline'

export default class extends Controller {
  static targets = ['editor', 'controller', 'input']

  connect() {
    this.initEditor()
  }

  initEditor = () => {
    this.boldButton = this.editorTarget.querySelector(".tiptap__button--bold")
    this.italicButton = this.editorTarget.querySelector(".tiptap__button--italic")
    this.underlineButton = this.editorTarget.querySelector(".tiptap__button--underline")
    this.olButton = this.editorTarget.querySelector(".tiptap__button--ol")
    this.ulButton = this.editorTarget.querySelector(".tiptap__button--ul")

    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        StarterKit,
        Underline,
      ],
      type: 'HTML',
      content: this.inputTarget.value,
      onUpdate: this.onUpdate,
      onSelectionUpdate: this.onSelectionUpdate,
    })
  }

  onUpdate = () => {
    this.inputTarget.value = this.editor.getHTML()
  }

  onSelectionUpdate = () => {
    this.boldButton.classList.toggle("tiptap__button--selected", this.editor.isActive('bold'))
    this.italicButton.classList.toggle("tiptap__button--selected", this.editor.isActive('italic'))
    this.underlineButton.classList.toggle("tiptap__button--selected", this.editor.isActive('underline'))
    this.ulButton.classList.toggle("tiptap__button--selected", this.editor.isActive('bulletList'))
    this.olButton.classList.toggle("tiptap__button--selected", this.editor.isActive('orderedList'))
  }

  bold(event) {
    const button = event.target.closest(".tiptap__button")

    if (!this.editor.view.state.selection.empty) {
      if (this.editor.isActive('bold')) {
        this.editor.chain().focus().extendMarkRange('bold').toggleBold().run()
      } else {
        this.editor.chain().focus().toggleBold().run()
      }
      button.classList.toggle("tiptap__button--selected", this.editor.isActive('bold'))
    } else {
      if (this.editor.isActive('bold')) {
        this.editor.chain().focus().extendMarkRange('bold').toggleBold().run()
      }
    }
  }

  italic(event) {
    const button = event.target.closest(".tiptap__button")

    if (!this.editor.view.state.selection.empty) {
      if (this.editor.isActive('italic')) {
        this.editor.chain().focus().extendMarkRange('italic').toggleItalic().run()
      } else {
        this.editor.chain().focus().toggleItalic().run()
      }
      button.classList.toggle("tiptap__button--selected", this.editor.isActive('italic'))
    } else {
      if (this.editor.isActive('italic')) {
        this.editor.chain().focus().extendMarkRange('italic').toggleItalic().run()
      }
    }
  }

  underline(event) {
    const button = event.target.closest(".tiptap__button")

    if (!this.editor.view.state.selection.empty) {
      if (this.editor.isActive('underline')) {
        this.editor.chain().focus().extendMarkRange('underline').toggleUnderline().run()
      } else {
        this.editor.chain().focus().toggleUnderline().run()
      }
      button.classList.toggle("tiptap__button--selected", this.editor.isActive('underline'))
    } else {
      if (this.editor.isActive('underline')) {
        this.editor.chain().focus().extendMarkRange('underline').toggleUnderline().run()
      }
    }
  }

  unorderedList(event) {
    const button = event.target.closest(".tiptap__button")

    if (this.editor.isActive("orderedList") && !this.editor.isActive("bulletList")) {
      this.editor.chain().focus().extendMarkRange('link').toggleOrderedList().run()
      this.olButton.classList.toggle("tiptap__button--selected", this.editor.isActive('orderedList'))
    }

    this.editor.chain().focus().toggleBulletList().run()
    button.classList.toggle("tiptap__button--selected", this.editor.isActive('bulletList'))
  }

  orderedList(event) {
    const button = event.target.closest(".tiptap__button")

    if (!this.editor.isActive("orderedList") && this.editor.isActive("bulletList")) {
      this.editor.chain().focus().extendMarkRange('link').toggleBulletList().run()
      this.ulButton.classList.toggle("tiptap__button--selected", this.editor.isActive('bulletList'))
    }

    this.editor.chain().focus().toggleOrderedList().run()
    button.classList.toggle("tiptap__button--selected", this.editor.isActive('orderedList'))

  }

  disconnect() {
    this.editor.destroy()
  }
}
