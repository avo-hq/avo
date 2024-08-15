export const textAlignLeft = (editor, updateButtonGroupState) => {
  setTextAlign(editor, "left", updateButtonGroupState);
};

export const textAlignCenter = (editor, updateButtonGroupState) => {
  setTextAlign(editor, "center", updateButtonGroupState);
};

export const textAlignRight = (editor, updateButtonGroupState) => {
  setTextAlign(editor, "right", updateButtonGroupState);
};

export const textAlignJustify = (editor, updateButtonGroupState) => {
  setTextAlign(editor, "justify", updateButtonGroupState);
};

const setTextAlign = (editor, align, updateButtonGroupState) => {
  editor.chain().focus().setTextAlign(align).run();
  updateButtonGroupState("textAlign");
};
