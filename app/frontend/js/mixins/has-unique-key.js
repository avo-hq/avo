export default {
  methods: {
    uniqueKey(field, index) {
      let key = `${field.id}-${field.component}`

      if (index) key += `-${index}`

      return key
    },
  },
}
