import { Controller } from "@hotwired/stimulus";
import { initializeEditor } from "./tiptap/editor_initializer";
import { initializeToolbar } from "./tiptap/toolbar_initializer";

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

    this.updateLinkArea();
    this.updateLinkButtonState();
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

  bold = () => this.toggleMark("toggleBold", "bold");
  italic = () => this.toggleMark("toggleItalic", "italic");
  underline = () => this.toggleMark("toggleUnderline", "underline");
  strike = () => this.toggleMark("toggleStrike", "strike");
  textAlignLeft = () => this.setTextAlign("left");
  textAlignCenter = () => this.setTextAlign("center");
  textAlignRight = () => this.setTextAlign("right");
  textAlignJustify = () => this.setTextAlign("justify");
  unorderedList = () => this.toggleList("toggleBulletList", "bulletList");
  orderedList = () => this.toggleList("toggleOrderedList", "orderedList");

  toggleMark = (method, action) => {
    this.editor.chain().focus()[method]().run();
    this.updateButtonState(action);
  };

  setTextAlign = (align) => {
    this.editor.chain().focus().setTextAlign(align).run();
    this.updateButtonGroupState("textAlign");
  };

  toggleList = (method, action) => {
    this.editor.chain().focus()[method]().run();
    this.updateButtonState(action);
  };

  toggleLinkArea = (event) => {
    const button = event.target.closest(".tiptap__button");

    if (button.classList.contains("tiptap__button--selected")) {
      this.linkArea.classList.add("hidden");
      button.classList.remove("tiptap__button--selected");
    } else if (!this.editor.view.state.selection.empty) {
      this.linkArea.classList.remove("hidden");
      button.classList.add("tiptap__button--selected");
    }
  };

  setLink = () => {
    const url = this.linkInput.value;

    if (url) {
      this.editor
        .chain()
        .focus()
        .extendMarkRange("link")
        .setLink({ href: url })
        .run();
      this.unsetButton.classList.remove("hidden");
    } else {
      this.unsetLink();
    }
  };

  unsetLink = () => {
    this.editor.chain().focus().extendMarkRange("link").unsetLink().run();
    this.unsetButton.classList.add("hidden");
  };

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
