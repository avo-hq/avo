import snakeCase from 'lodash/snakeCase'

export default {
  methods: {
    uniqueKey(field) {
      const key = `${snakeCase(field.name)}-${field.id}`

      return key
    },
  },
}
