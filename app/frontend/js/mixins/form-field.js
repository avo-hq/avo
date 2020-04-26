export default {
  data: () => ({
    value: ''
  }),
  methods: {
    setInitialValue(){
      this.value = this.field.value
    },
    getValue(){
      return this.value
    },
  },
  mounted() {
    this.setInitialValue()

    this.field.getValue = this.getValue
  }
}