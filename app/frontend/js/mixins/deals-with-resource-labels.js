import lowerCase from 'lodash/lowerCase'
import pluralize from 'pluralize'
import upperFirst from 'lodash/upperFirst'

export default {
  filters: {
    toLowerCase(value) {
      return value.toLowerCase()
    },
  },
  computed: {
    sentencedCase() {
      return upperFirst(lowerCase(this.resourceName))
    },
    resourceNameSingular() {
      return pluralize(this.sentencedCase, 1)
    },
    resourceNamePlural() {
      return this.sentencedCase.charAt(0).toUpperCase() + this.sentencedCase.slice(1)
    },
  },
}
