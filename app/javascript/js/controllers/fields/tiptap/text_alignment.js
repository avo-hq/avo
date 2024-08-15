import { updateButtonGroupState } from "./editor_helpers";

export const textAlignLeft = (editor, buttons) => {
  setTextAlign(editor, "left", buttons);
};

export const textAlignCenter = (editor, buttons) => {
  setTextAlign(editor, "center", buttons);
};

export const textAlignRight = (editor, buttons) => {
  setTextAlign(editor, "right", buttons);
};

export const textAlignJustify = (editor, buttons) => {
  setTextAlign(editor, "justify", buttons);
};

const setTextAlign = (editor, align, buttons) => {
  editor.chain().focus().setTextAlign(align).run();
  updateButtonGroupState(editor, "textAlign", buttons);
};
