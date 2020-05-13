export default {
  computed: {
    hasFields() {
      return this.fields.length > 0
    },
    fields() {
      return this.resourceFields.filter((field) => !this.hiddenFields.includes(field))
    },
    hiddenFields() {
      return this.resourceFields.filter((field) => field.is_relation && field.resource_name_plural && field.resource_name_plural.toLowerCase() === this.$route.params.resourceName)
    },
  },
}
