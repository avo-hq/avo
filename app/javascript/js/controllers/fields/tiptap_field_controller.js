import { Controller } from "@hotwired/stimulus";
import { initializeEditor } from "./tiptap/editor_initializer";
import { initializeToolbar } from "./tiptap/toolbar_initializer";
import { bold, italic, underline, strike } from "./tiptap/text_formatting";
import { unorderedList, orderedList } from "./tiptap/lists";

import {
  textAlignLeft,
  textAlignCenter,
  textAlignRight,
  textAlignJustify,
} from "./tiptap/text_alignment";

import {
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

  onUpdate = () => {
    this.inputTarget.value = this.editor.getHTML();
  };

  onSelectionUpdate = () => {
    Object.keys(this.buttons).forEach((action) => {
      const isActive = this.editor.isActive(this.convertActionToObject(action));
      this.toggleButtonState(action, isActive);
    });

    updateLinkArea(
      this.editor,
      this.linkArea,
      this.unsetButton,
      this.linkInput
    );

    updateLinkButtonState(this.editor, this.buttons);
  };

  handleButtonClick = (event) => {
    const action = event.target.dataset.action;
    if (action && this[action]) {
      this[action](event);
    }
  };

  toggleButtonState = (action, isActive) => {
    this.buttons[action].classList.toggle("tiptap__button--selected", isActive);

    if (action === "link") {
      this.buttons[action].disabled =
        this.editor.view.state.selection.empty && !isActive;
    }
  };

  updateLinkArea = () => {
    const isLinkActive = this.editor.isActive("link");
    this.linkArea.classList.toggle("hidden", !isLinkActive);
    this.unsetButton.classList.toggle("hidden", !isLinkActive);
    this.linkInput.value = isLinkActive
      ? this.editor.getAttributes("link").href
      : "";
  };

  updateButtonState = (action) => {
    const actionString =
      typeof action === "object" ? this.convertObjectToAction(action) : action;

    this.buttons[actionString].classList.toggle(
      "tiptap__button--selected",
      this.editor.isActive(action)
    );
  };

  updateLinkButtonState = () => {
    const isLinkActive = this.editor.isActive("toggleLinkArea");
    const isSelectionEmpty = this.editor.view.state.selection.empty;
    this.buttons["toggleLinkArea"].disabled = isSelectionEmpty && !isLinkActive;
  };

  updateButtonGroupState = (action) => {
    if (action === "textAlign") {
      this.updateButtonState({ textAlign: "left" });
      this.updateButtonState({ textAlign: "center" });
      this.updateButtonState({ textAlign: "right" });
      this.updateButtonState({ textAlign: "justify" });
    }
  };

  bold = () => bold(this.editor, this.updateButtonState);
  italic = () => italic(this.editor, this.updateButtonState);
  underline = () => underline(this.editor, this.updateButtonState);
  strike = () => strike(this.editor, this.updateButtonState);

  textAlignLeft = () => textAlignLeft(this.editor, this.updateButtonGroupState);
  textAlignCenter = () =>
    textAlignCenter(this.editor, this.updateButtonGroupState);
  textAlignRight = () =>
    textAlignRight(this.editor, this.updateButtonGroupState);
  textAlignJustify = () =>
    textAlignJustify(this.editor, this.updateButtonGroupState);

  unorderedList = () => unorderedList(this.editor, this.updateButtonState);
  orderedList = () => orderedList(this.editor, this.updateButtonState);

  toggleLinkArea = (event) => toggleLinkArea(this.editor, this.linkArea, event);
  setLink = () => setLink(this.editor, this.linkInput, this.unsetButton);
  unsetLink = () => unsetLink(this.editor, this.unsetButton);

  preventEnter = (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
    }
  };

  convertObjectToAction = (actionObject) => {
    return Object.keys(actionObject)[0].concat(
      this.capitalize(Object.values(actionObject)[0])
    );
  };

  convertActionToObject = (actionString) => {
    return actionString.includes("textAlign")
      ? { textAlign: actionString.replace("textAlign", "").toLowerCase() }
      : actionString;
  };

  capitalize = (string) => {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  disconnect() {
    this.editor.destroy();
  }
}
