import { Controller } from '@hotwired/stimulus'
import { Editor } from '@tiptap/core'

import Bold from '@tiptap/extension-bold'
import BulletList from '@tiptap/extension-bullet-list'
import Document from '@tiptap/extension-document'
import HardBreak from '@tiptap/extension-hard-break'
import Italic from '@tiptap/extension-italic'
import Link from '@tiptap/extension-link'
import ListItem from '@tiptap/extension-list-item'
import OrderedList from '@tiptap/extension-ordered-list'
import Paragraph from '@tiptap/extension-paragraph'
import Strike from '@tiptap/extension-strike'
import Text from '@tiptap/extension-text'
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
    this.strikeButton = this.editorTarget.querySelector(".tiptap__button--strike")
    this.olButton = this.editorTarget.querySelector(".tiptap__button--ol")
    this.ulButton = this.editorTarget.querySelector(".tiptap__button--ul")
    this.linkButton = this.editorTarget.querySelector(".tiptap__button--link")

    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        Bold,
        BulletList,
        Document,
        HardBreak,
        Italic,
        Link.configure({
          openOnClick: false,
        }),
        ListItem,
        OrderedList,
        Paragraph,
        Strike,
        Text,
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
    this.strikeButton.classList.toggle("tiptap__button--selected", this.editor.isActive('strike'))
    this.ulButton.classList.toggle("tiptap__button--selected", this.editor.isActive('bulletList'))
    this.olButton.classList.toggle("tiptap__button--selected", this.editor.isActive('orderedList'))
    this.linkButton.classList.toggle("tiptap__button--selected", this.editor.isActive('link'))
    this.linkArea = this.element.querySelector(".tiptap__link-area")
    this.linkInput = this.element.querySelector(".tiptap__link-field")
    this.unsetButton = this.element.querySelector(".tiptap__link-button--unset")

    if (!this.editor.isActive('link')) {
      this.linkArea.classList.toggle("hidden", true)
      this.linkInput.value = ""
      this.unsetButton.classList.toggle("hidden", true)
    } else {
      this.linkArea.classList.toggle("hidden", false)
      let previousUrl = this.editor.getAttributes('link').href
      this.linkInput.value = previousUrl
      this.unsetButton.classList.toggle("hidden", false)
    }
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

  strike(event) {
    const button = event.target.closest(".tiptap__button")

    if (!this.editor.view.state.selection.empty) {
      if (this.editor.isActive('strike')) {
        this.editor.chain().focus().extendMarkRange('strike').toggleStrike().run()
      } else {
        this.editor.chain().focus().toggleStrike().run()
      }
      button.classList.toggle("tiptap__button--selected", this.editor.isActive('strike'))
    } else {
      if (this.editor.isActive('strike')) {
        this.editor.chain().focus().extendMarkRange('strike').toggleStrike().run()
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

  toggleLinkArea(event) {
    const button = event.target.closest(".tiptap__button")
    const linkArea = this.element.querySelector(".tiptap__link-area")
    const previousUrl = this.editor.getAttributes('link').href
    const linkInput = this.element.querySelector(".tiptap__link-field")

    if (previousUrl) {
      linkInput.value = previousUrl
    }

    if (button.classList.contains("tiptap__button--selected")) {
      linkArea.classList.toggle("hidden", true)
      button.classList.toggle("tiptap__button--selected", false)
    } else {
      if (!this.editor.view.state.selection.empty) {
        linkArea.classList.toggle("hidden", false)
        button.classList.toggle("tiptap__button--selected", true)
      }
    }
  }

  setLink(event) {
    const button = event.target.closest(".tiptap__button")
    const linkInput = this.element.querySelector(".tiptap__link-field").value
    const previousUrl = this.editor.getAttributes('link').href
    const unsetButton = this.element.querySelector(".tiptap__link-button--unset")


    if (linkInput) {
      this.editor.chain().focus().extendMarkRange('link').setLink({ href: linkInput }).run()
      unsetButton.classList.toggle("hidden", false)
    } else {
      this.editor.chain().focus().extendMarkRange('link').unsetLink().run()
      unsetButton.classList.toggle("hidden", true)
    }

  }

  unsetLink(event) {
    const button = event.target.closest(".tiptap__button")
    const linkInput = this.element.querySelector(".tiptap__link-field").value
    const previousUrl = this.editor.getAttributes('link').href
    const unsetButton = this.element.querySelector(".tiptap__link-button--unset")

    this.editor.chain().focus().extendMarkRange('link').unsetLink().run()
    unsetButton.classList.toggle("hidden", true)

  }

  preventEnter(event){
    if (event.key === 'Enter' || event.keyCode === 13) {
      event.preventDefault()
    }
  }

  disconnect() {
    this.editor.destroy()
  }
}
