export const initializeToolbar = (buttons, handleButtonClick) => {
  Object.values(buttons).forEach((button) => {
    button.addEventListener("click", handleButtonClick);
  });
};
