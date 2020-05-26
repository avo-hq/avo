export default {
  computed: {
    classes() {
      const classes = ['flex', 'items-start', 'py-2', 'leading-tight']

      if (this.index !== 0) classes.push('border-t')

      return classes.join(' ')
    },
    valueSlotClasses() {
      const classes = ['p-4', 'self-center']

      if (this.valueSlotFullWidth) {
        classes.push('flex-1')
      } else {
        classes.push('w-1/2')
      }

      return classes.join(' ')
    },
  },
}
