export default {
  computed: {
    classes() {
      const classes = ['flex', 'items-start', 'py-1', 'leading-tight']

      if (this.index !== 0) classes.push('border-t')

      return classes.join(' ')
    },
    valueSlotClasses() {
      const classes = ['p-4', 'self-center']

      if (this.valueSlotFullWidth) {
        classes.push('flex-1')
      } else {
        classes.push('w-7/12')
      }

      return classes.join(' ')
    },
  },
}
