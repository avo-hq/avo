import { Controller } from "@hotwired/stimulus";
import { Editor } from "@tiptap/core";

import Bold from "@tiptap/extension-bold";
import BulletList from "@tiptap/extension-bullet-list";
import Document from "@tiptap/extension-document";
import HardBreak from "@tiptap/extension-hard-break";
import Italic from "@tiptap/extension-italic";
import Link from "@tiptap/extension-link";
import ListItem from "@tiptap/extension-list-item";
import OrderedList from "@tiptap/extension-ordered-list";
import Paragraph from "@tiptap/extension-paragraph";
import Placeholder from "@tiptap/extension-placeholder";
import Strike from "@tiptap/extension-strike";
import Text from "@tiptap/extension-text";
import TextAlign from "@tiptap/extension-text-align";
import Underline from "@tiptap/extension-underline";

export default class extends Controller {
  static targets = ["editor", "controller", "input"];

  connect() {
    this.initEditor();
    this.initToolbar();
  }

  initEditor = () => {
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
        Placeholder.configure({
          placeholder: this.inputTarget.placeholder,
        }),
        Strike,
        Text,
        TextAlign.configure({
          types: ["heading", "paragraph"],
        }),
        Underline,
      ],
      type: "HTML",
      content: this.inputTarget.value,
      onUpdate: this.onUpdate,
      onSelectionUpdate: this.onSelectionUpdate,
    });
  };

  initToolbar = () => {
    this.buttons = {
      bold: this.element.querySelector(".tiptap__button--bold"),
      italic: this.element.querySelector(".tiptap__button--italic"),
      underline: this.element.querySelector(".tiptap__button--underline"),
      strike: this.element.querySelector(".tiptap__button--strike"),
      bulletList: this.element.querySelector(".tiptap__button--ul"),
      orderedList: this.element.querySelector(".tiptap__button--ol"),
      link: this.element.querySelector(".tiptap__button--link"),
      textAlignLeft: this.element.querySelector(".tiptap__button--align-left"),
      textAlignCenter: this.element.querySelector(
        ".tiptap__button--align-center"
      ),
      textAlignRight: this.element.querySelector(
        ".tiptap__button--align-right"
      ),
      textAlignJustify: this.element.querySelector(
        ".tiptap__button--align-justify"
      ),
    };

    this.linkArea = this.element.querySelector(".tiptap__link-area");
    this.linkInput = this.element.querySelector(".tiptap__link-field");
    this.unsetButton = this.element.querySelector(
      ".tiptap__link-button--unset"
    );
  };

  onUpdate = () => {
    this.inputTarget.value = this.editor.getHTML();
  };

  onSelectionUpdate = () => {
    Object.keys(this.buttons).forEach((actionString) => {
      const isActive = this.editor.isActive(
        this.actionStringToAction(actionString)
      );

      this.buttons[actionString].classList.toggle(
        "tiptap__button--selected",
        isActive
      );

      if (actionString === "link") {
        this.buttons[actionString].disabled =
          this.editor.view.state.selection.empty && !isActive;
      }
    });

    this.updateLinkArea();
    this.updateLinkButtonState();
  };

  handleButtonClick(event) {
    const action = event.target.dataset.action;
    if (action && this[action]) {
      this[action](event);
    }
  }

  updateButtonState(action) {
    const actionString = this.actionString(action);

    this.buttons[actionString].classList.toggle(
      "tiptap__button--selected",
      this.editor.isActive(action)
    );
  }

  updateButtonGroupState(action) {
    if (action === "textAlign") {
      this.updateButtonState({ textAlign: "left" });
      this.updateButtonState({ textAlign: "center" });
      this.updateButtonState({ textAlign: "right" });
      this.updateButtonState({ textAlign: "justify" });
    }
  }

  updateLinkButtonState() {
    const isLinkActive = this.editor.isActive("link");
    const isSelectionEmpty = this.editor.view.state.selection.empty;
    this.buttons.link.disabled = isSelectionEmpty && !isLinkActive;
  }

  updateLinkArea() {
    const isLinkActive = this.editor.isActive("link");
    this.linkArea.classList.toggle("hidden", !isLinkActive);
    this.unsetButton.classList.toggle("hidden", !isLinkActive);

    if (isLinkActive) {
      const previousUrl = this.editor.getAttributes("link").href;
      this.linkInput.value = previousUrl || "";
    } else {
      this.linkInput.value = "";
    }
  }

  bold() {
    this.editor.chain().focus().toggleBold().run();
    this.updateButtonState("bold");
  }

  italic() {
    this.editor.chain().focus().toggleItalic().run();
    this.updateButtonState("italic");
  }

  underline() {
    this.editor.chain().focus().toggleUnderline().run();
    this.updateButtonState("underline");
  }

  strike() {
    this.editor.chain().focus().toggleStrike().run();
    this.updateButtonState("strike");
  }

  textAlignLeft() {
    this.editor.chain().focus().setTextAlign("left").run();
    this.updateButtonGroupState("textAlign");
  }

  textAlignCenter() {
    this.editor.chain().focus().setTextAlign("center").run();
    this.updateButtonGroupState("textAlign");
  }

  textAlignRight() {
    this.editor.chain().focus().setTextAlign("right").run();
    this.updateButtonGroupState("textAlign");
  }

  textAlignJustify() {
    this.editor.chain().focus().setTextAlign("justify").run();
    this.updateButtonGroupState("textAlign");
  }

  unorderedList() {
    this.editor.chain().focus().toggleBulletList().run();
    this.updateButtonState("bulletList");
  }

  orderedList() {
    this.editor.chain().focus().toggleOrderedList().run();
    this.updateButtonState("orderedList");
  }

  toggleLinkArea(event) {
    const button = event.target.closest(".tiptap__button");
    const linkArea = this.element.querySelector(".tiptap__link-area");
    const previousUrl = this.editor.getAttributes("link").href;
    const linkInput = this.element.querySelector(".tiptap__link-field");

    if (previousUrl) {
      linkInput.value = previousUrl;
    }

    if (button.classList.contains("tiptap__button--selected")) {
      linkArea.classList.toggle("hidden", true);
      button.classList.toggle("tiptap__button--selected", false);
    } else {
      if (!this.editor.view.state.selection.empty) {
        linkArea.classList.toggle("hidden", false);
        button.classList.toggle("tiptap__button--selected", true);
      }
    }
  }

  setLink() {
    const linkInput = this.element.querySelector(".tiptap__link-field").value;
    const unsetButton = this.element.querySelector(
      ".tiptap__link-button--unset"
    );

    if (linkInput) {
      this.editor
        .chain()
        .focus()
        .extendMarkRange("link")
        .setLink({ href: linkInput })
        .run();
      unsetButton.classList.toggle("hidden", false);
    } else {
      this.editor.chain().focus().extendMarkRange("link").unsetLink().run();
      unsetButton.classList.toggle("hidden", true);
    }
  }

  unsetLink() {
    const unsetButton = this.element.querySelector(
      ".tiptap__link-button--unset"
    );

    this.editor.chain().focus().extendMarkRange("link").unsetLink().run();
    unsetButton.classList.toggle("hidden", true);
  }

  preventEnter(event) {
    if (event.key === "Enter" || event.keyCode === 13) {
      event.preventDefault();
    }
  }

  actionString(action) {
    return typeof action === "object"
      ? this.actionObjectToString(action)
      : action;
  }

  actionStringToAction(actionString) {
    return actionString.includes("textAlign")
      ? { textAlign: actionString.replace("textAlign", "").toLowerCase() }
      : actionString;
  }

  actionObjectToString(object) {
    return Object.keys(object)[0].concat(
      this.capitalize(Object.values(object)[0])
    );
  }

  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  disconnect() {
    this.editor.destroy();
  }
}
