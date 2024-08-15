import { Controller } from "@hotwired/stimulus";
import { initializeEditor } from "./tiptap/editor_initializer";
import { initializeToolbar } from "./tiptap/toolbar_initializer";
import { bold, italic, underline, strike } from "./tiptap/text_formatting";
import { unorderedList, orderedList } from "./tiptap/lists";
import { updateAllButtonsStates } from "./tiptap/editor_helpers";

import {
  textAlignLeft,
  textAlignCenter,
  textAlignRight,
  textAlignJustify,
} from "./tiptap/text_alignment";

import {
  preventEnter,
  toggleLinkArea,
  setLink,
  unsetLink,
  updateLinkArea,
  updateLinkButtonState,
} from "./tiptap/links";

export default class extends Controller {
  static targets = ["editor", "controller", "input"];

  connect() {
    this.initElements();
    this.initEditor();
    this.initToolbar();
  }

  disconnect() {
    this.editor.destroy();
  }

  initElements = () => {
    this.buttons = Array.from(
      this.element.querySelectorAll(".tiptap__button")
    ).reduce((acc, button) => {
      acc[button.dataset.action.split("#")[1]] = button;
      return acc;
    }, {});

    this.linkArea = this.element.querySelector(".tiptap__link-area");
    this.linkInput = this.element.querySelector(".tiptap__link-field");
    this.unsetButton = this.element.querySelector(
      ".tiptap__link-button--unset"
    );
  };

  initEditor = () => {
    this.editor = initializeEditor(
      this.editorTarget,
      this.inputTarget,
      this.onUpdate,
      this.onSelectionUpdate
    );
  };

  initToolbar = () => {
    initializeToolbar(this.buttons, this.handleButtonClick);
  };

  handleButtonClick = (event) => {
    const action = event.target.dataset.action;
    if (action && this[action]) {
      this[action](event);
    }
  };

  onUpdate = () => {
    this.inputTarget.value = this.editor.getHTML();
  };

  onSelectionUpdate = () => {
    updateAllButtonsStates(this.editor, this.buttons);

    updateLinkArea(
      this.editor,
      this.linkArea,
      this.unsetButton,
      this.linkInput
    );

    updateLinkButtonState(this.editor, this.buttons);
  };

  // Text formatting
  bold = () => bold(this.editor, this.buttons);
  italic = () => italic(this.editor, this.buttons);
  underline = () => underline(this.editor, this.buttons);
  strike = () => strike(this.editor, this.buttons);

  // Text alignment
  textAlignLeft = () => textAlignLeft(this.editor, this.buttons);
  textAlignCenter = () => textAlignCenter(this.editor, this.buttons);
  textAlignRight = () => textAlignRight(this.editor, this.buttons);
  textAlignJustify = () => textAlignJustify(this.editor, this.buttons);

  // Lists
  unorderedList = () => unorderedList(this.editor, this.buttons);
  orderedList = () => orderedList(this.editor, this.buttons);

  // Links
  toggleLinkArea = (event) => toggleLinkArea(this.editor, this.linkArea, event);
  setLink = () => setLink(this.editor, this.linkInput, this.unsetButton);
  unsetLink = () => unsetLink(this.editor, this.unsetButton);
  preventEnter = (event) => preventEnter(event);
}
