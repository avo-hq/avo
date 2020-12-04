import I18n from 'i18n-js'
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
    translationKey() {
      if (this.hasManyThrough) return this.field.translation_key
      if (this.resourceTranslationKey) return this.resourceTranslationKey
      if (this.meta && this.meta.translation_key) return this.meta.translation_key
      if (this.resource && this.resource.translationKey) return this.resource.translationKey

      return null
    },
    resourceNameSingular() {
      if (this.translationKey) return upperFirst(lowerCase(I18n.t(this.translationKey, { count: 1 })))

      return pluralize(upperFirst(lowerCase(this.resourceName)), 1)
    },
    resourceNamePlural() {
      if (this.translationKey) return upperFirst(lowerCase(I18n.t(this.translationKey, { count: 2 })))

      return upperFirst(lowerCase(this.resourceName))
    },
  },
}
