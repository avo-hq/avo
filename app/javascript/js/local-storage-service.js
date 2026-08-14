export class LocalStorageService {
  prefix = 'avo'

  prefixedKey(key) {
    return `${this.prefix}.${key}`
  }

  get(key) {
    try {
      return window.localStorage.getItem(this.prefixedKey(key))
    } catch {
      return null
    }
  }

  set(key, value) {
    try {
      return window.localStorage.setItem(this.prefixedKey(key), value)
    } catch {
      return null
    }
  }

  remove(key) {
    try {
      return window.localStorage.removeItem(this.prefixedKey(key))
    } catch {
      return null
    }
  }
}
