import { LocalStorageService } from './local-storage-service'
import { application } from './application'

class AvoHelper {
  configuration = window.AvoConfiguration

  menus = {
    resetCollapsedState() {
      Array.from(document.querySelectorAll('[data-menu-key-param]'))
        .map((i) => i.getAttribute('data-menu-key-param'))
        .filter(Boolean)
        .forEach((key) => {
          window.localStorage.removeItem(key)
        })
    },
  }

  localStorage = new LocalStorageService()

  registerController(name, controller) {
    console.log('registerController', name, controller)
    application.register(name, controller)
  }
}

// Initialize the main Avo object.
const Avo = new AvoHelper()
window.Avo = window.Avo || Avo

export { Avo }
