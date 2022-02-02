import { Controller } from 'stimulus'

export default class extends Controller {
  spinnerMarkup = `<div class="button-spinner">
  <div class="double-bounce1"></div>
  <div class="double-bounce2"></div>
</div>`;

  connect() {
    const button = this.context.scope.element
    this.context.scope.element.addEventListener('click', () => {
      button.style.width = `${button.getBoundingClientRect().width}px`
      button.style.height = `${button.getBoundingClientRect().height}px`
      button.innerHTML = this.spinnerMarkup
      button.classList.add('justify-center')

      setTimeout(() => {
        button.setAttribute('disabled', 'disabled')
      }, 1)
    })
  }
}
