import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  /**
  * Helper that parses the data attribute value to JSON
  */
  getJsonAttribute(target, attribute, defaultValue = []) {
    let result = defaultValue
    try {
      result = JSON.parse(target.getAttribute(attribute))
    } catch (error) {}

    return result
  }

  /**
  * Parses the attribute to boolean
  */
  getBooleanAttribute(target, attribute) {
    return target.getAttribute(attribute) === '1'
  }
}
