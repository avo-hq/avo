import { updateButtonState } from "./editor_helpers";

export const unorderedList = (editor, buttons) => {
  toggleList(editor, "toggleBulletList", "unorderedList", buttons);
};

export const orderedList = (editor, buttons) => {
  toggleList(editor, "toggleOrderedList", "orderedList", buttons);
};

const toggleList = (editor, method, action, buttons) => {
  editor.chain().focus()[method]().run();
  updateButtonState(editor, action, buttons);
};
