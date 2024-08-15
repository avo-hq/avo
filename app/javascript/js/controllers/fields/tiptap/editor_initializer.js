import { Editor } from "@tiptap/core";
import { extensions } from "./extensions";

export const initializeEditor = (
  editorTarget,
  inputTarget,
  onUpdate,
  onSelectionUpdate
) => {
  return new Editor({
    element: editorTarget,
    extensions: extensions(inputTarget),
    type: "HTML",
    content: inputTarget.value,
    onUpdate,
    onSelectionUpdate,
  });
};
