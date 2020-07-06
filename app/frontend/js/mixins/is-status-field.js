export default {
  computed: {
    status() {
      if (this.isFailing) return 'fail'
      if (this.isLoading) return 'load'

      return 'success'
    },
    isFailing() {
      return this.field.failed_when.indexOf(this.field.value) > -1
    },
    isLoading() {
      return this.field.loading_when.indexOf(this.field.value) > -1
    },
  },
}
