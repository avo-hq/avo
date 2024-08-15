import { updateButtonState } from "./editor_helpers";

export const bold = (editor, buttons) => {
  toggleMark(editor, "toggleBold", "bold", buttons);
};

export const italic = (editor, buttons) => {
  toggleMark(editor, "toggleItalic", "italic", buttons);
};

export const underline = (editor, buttons) => {
  toggleMark(editor, "toggleUnderline", "underline", buttons);
};

export const strike = (editor, buttons) => {
  toggleMark(editor, "toggleStrike", "strike", buttons);
};

const toggleMark = (editor, method, action, buttons) => {
  editor.chain().focus()[method]().run();
  updateButtonState(editor, action, buttons);
};
