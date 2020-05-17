import isUndefined from 'lodash/isUndefined'

export default {
  data: () => ({
    value: '',
  }),
  props: {
    field: {},
    index: {
      type: Number,
    },
    errors: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    hasErrors() {
      if (Object.keys(this.errors).length === 0) return false

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
  },
}
