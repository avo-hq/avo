export default {
  computed: {
    classes() {
      const classes = ['flex', 'items-start', 'py-1', 'leading-tight']

      if (this.index !== 0 || this.displayedInModal) classes.push('border-t')

      return classes.join(' ')
    },
    valueSlotClasses() {
      const classes = ['p-4', 'self-center']

      if (this.extraSlotVisible) {
        classes.push('w-7/12')
      } else {
        classes.push('flex-1')
      }

      return classes.join(' ')
    },
  },
}
