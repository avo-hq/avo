const closeModal = () => {
  document.querySelector(`turbo-frame#${window.Avo.configuration.modal_frame_id}`).innerHTML = ''
}

export { closeModal }
