export default {
  computed: {
    relationship() {
      if (this.field && this.field.relationship) return this.field.relationship

      return null
    },
    resourcePath() {
      if (this.resource && this.resource.path) {
        return this.resource.path
      }

      if (this.field && this.field.path) {
        return this.field.path
      }

      return this.resourceName.toLowerCase()
    },
  },
}
