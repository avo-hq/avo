export const toggleLinkArea = (editor, linkArea, event) => {
  const button = event.target.closest(".tiptap__button");

  if (button.classList.contains("tiptap__button--selected")) {
    linkArea.classList.add("hidden");
    button.classList.remove("tiptap__button--selected");
  } else if (!editor.view.state.selection.empty) {
    linkArea.classList.remove("hidden");
    button.classList.add("tiptap__button--selected");
  }
};

export const setLink = (editor, linkInput, unsetButton) => {
  const url = linkInput.value;

  if (url) {
    editor.chain().focus().extendMarkRange("link").setLink({ href: url }).run();
    unsetButton.classList.remove("hidden");
  } else {
    unsetLink(editor, unsetButton);
  }
};

export const unsetLink = (editor, unsetButton) => {
  editor.chain().focus().extendMarkRange("link").unsetLink().run();
  unsetButton.classList.add("hidden");
};

export const updateLinkArea = (editor, linkArea, unsetButton, linkInput) => {
  const isLinkActive = editor.isActive("link");
  linkArea.classList.toggle("hidden", !isLinkActive);
  unsetButton.classList.toggle("hidden", !isLinkActive);
  linkInput.value = isLinkActive ? editor.getAttributes("link").href : "";
};

export const updateLinkButtonState = (editor, buttons) => {
  const isLinkActive = editor.isActive("toggleLinkArea");
  const isSelectionEmpty = editor.view.state.selection.empty;
  buttons["toggleLinkArea"].disabled = isSelectionEmpty && !isLinkActive;
};
