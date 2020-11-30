import upperFirst from 'lodash/upperFirst'

export default {
  filters: {
    upperFirst(value) {
      return upperFirst(value)
    },
  },
}
