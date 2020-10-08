export default {
  data: () => ({
    actionsBus: [],
  }),
  methods: {
    addToBus(method) {
      this.actionsBus.push(method)
    },
  },
  async mounted() {
    await Promise.all(this.actionsBus.map((method) => method()))
  },
}
