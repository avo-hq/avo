export const unorderedList = (editor, updateButtonState) => {
  toggleList(editor, "toggleBulletList", "unorderedList", updateButtonState);
};

export const orderedList = (editor, updateButtonState) => {
  toggleList(editor, "toggleOrderedList", "orderedList", updateButtonState);
};

const toggleList = (editor, method, action, updateButtonState) => {
  editor.chain().focus()[method]().run();
  updateButtonState(action);
};
