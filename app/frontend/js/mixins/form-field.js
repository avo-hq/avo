import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  data: () => ({
    value: '',
  }),
  props: {
    field: {},
    resourceName: {},
    resourceId: {},
    index: {
      type: Number,
    },
    errors: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    disabled() {
      return this.field.readonly
    },
    fieldError() {
      if (!this.hasErrors) return ''

      return `${this.field.id} ${this.errors[this.field.id].join(', ')}`
    },
    hasErrors() {
      if (isUndefined(this.errors)
          || isNull(this.errors)
          || Object.keys(this.errors).length === 0) return false

      return !isUndefined(this.errors[this.field.id])
    },
  },
  methods: {
    setInitialValue() {
      this.value = this.field.value
    },
    getValue() {
      return this.value
    },
  },
  mounted() {
    this.setInitialValue()

    this.field.getValue = this.getValue
    this.field.getFileFieldValue = this.getFileFieldValue
  },
}
