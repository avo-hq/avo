export class LocalStorageService {
  prefix = 'avo'

  prefixedKey(key) {
    return `${this.prefix}.${key}`
  }

  get(key) {
    return window.localStorage.getItem(this.prefixedKey(key))
  }

  set(key, value) {
    return window.localStorage.setItem(this.prefixedKey(key), value)
  }

  remove(key) {
    return window.localStorage.removeItem(this.prefixedKey(key))
  }
}
