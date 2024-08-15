export const updateButtonState = (editor, action, buttons) => {
  const actionString =
    typeof action === "object" ? convertObjectToAction(action) : action;

  buttons[actionString].classList.toggle(
    "tiptap__button--selected",
    editor.isActive(action)
  );
};

export const updateButtonGroupState = (editor, action, buttons) => {
  if (action === "textAlign") {
    updateButtonState(editor, { textAlign: "left" }, buttons);
    updateButtonState(editor, { textAlign: "center" }, buttons);
    updateButtonState(editor, { textAlign: "right" }, buttons);
    updateButtonState(editor, { textAlign: "justify" }, buttons);
  }
};

export const updateAllButtonsStates = (editor, buttons) => {
  Object.keys(buttons).forEach((action) => {
    const isActive = editor.isActive(convertActionToObject(action));
    toggleButtonState(editor, buttons, action, isActive);
  });
};

const toggleButtonState = (editor, buttons, action, isActive) => {
  buttons[action].classList.toggle("tiptap__button--selected", isActive);

  if (action === "link") {
    buttons[action].disabled = editor.view.state.selection.empty && !isActive;
  }
};

const convertObjectToAction = (actionObject) => {
  return Object.keys(actionObject)[0].concat(
    capitalize(Object.values(actionObject)[0])
  );
};

const convertActionToObject = (actionString) => {
  return actionString.includes("textAlign")
    ? { textAlign: actionString.replace("textAlign", "").toLowerCase() }
    : actionString;
};

const capitalize = (string) => {
  return string.charAt(0).toUpperCase() + string.slice(1);
};
