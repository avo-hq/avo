import lowerCase from 'lodash/lowerCase'
import upperFirst from 'lodash/upperFirst'

export default {
  filters: {
    toLowerCase(value) {
      return value.toLowerCase()
    },
  },
  computed: {
    sentencedCase() {
      if (this.meta && this.meta.translation_key) return upperFirst(lowerCase(this.$t(this.meta.translation_key)))

      return upperFirst(lowerCase(this.resourceName))
    },
    resourceNameSingular() {
      return this.sentencedCase
    },
    resourceNamePlural() {
      if (this.meta && this.meta.translation_key) return upperFirst(lowerCase(this.$tc(this.meta.translation_key, 2)))

      return this.sentencedCase
    },
  },
}
