export const bold = (editor, updateButtonState) => {
  toggleMark(editor, "toggleBold", "bold", updateButtonState);
};

export const italic = (editor, updateButtonState) => {
  toggleMark(editor, "toggleItalic", "italic", updateButtonState);
};

export const underline = (editor, updateButtonState) => {
  toggleMark(editor, "toggleUnderline", "underline", updateButtonState);
};

export const strike = (editor, updateButtonState) => {
  toggleMark(editor, "toggleStrike", "strike", updateButtonState);
};

const toggleMark = (editor, method, action, updateButtonState) => {
  editor.chain().focus()[method]().run();
  updateButtonState(action);
};
