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
    setInitialConfig() {},
    setInitialValue() {
      this.value = this.field.value
    },
    getValue() {
      return this.value
    },
    getId() {
      return this.field.id
    },
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].focus()
    },
  },
  created() {
    this.setInitialConfig()
  },
  mounted() {
    this.setInitialValue()

    this.field.getId = this.getId
    this.field.getValue = this.getValue

    if (this.index === 0) {
      this.focus()
    }
  },
}
