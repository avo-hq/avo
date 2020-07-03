<template>
  <span :class="classes" v-text="label"/>
</template>

<script>
export default {
  props: {
    type: String,
    label: String,
  },
  computed: {
    classes() {
      const classes = ['whitespace-no-wrap', 'rounded-full', 'uppercase', 'px-2', 'text-xs', 'font-bold', 'text-white']

      const backgrounds = {
        info: 'blue',
        success: 'green',
        danger: 'red',
        warning: 'yellow',
      }

      classes.push(`bg-${backgrounds[this.type]}-500`)

      return classes.join(' ')
    },
  },
}
</script>
