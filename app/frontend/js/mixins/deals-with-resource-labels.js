import pluralize from 'pluralize'

export default {
  filters: {
    toLowerCase(value) {
      return value.toLowerCase()
    },
  },
  computed: {
    resourceNameSingular() {
      return pluralize(this.resourceName, 1)
    },
    resourceNamePlural() {
      return this.resourceName.charAt(0).toUpperCase() + this.resourceName.slice(1)
    },
  },
}
