export default {
  data: () => ({
    value: '',
  }),
  props: {
    index: {
      type: Number,
    },
    errors: {
      type: Object,
      default: () => ({}),
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
