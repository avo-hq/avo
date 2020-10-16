<template>
  <span :class="classes"
    style="max-width: 120px;"
    v-text="label"
  />
</template>

<script>
export default {
  props: {
    type: String,
    label: String,
  },
  computed: {
    classes() {
      const classes = ['whitespace-no-wrap', 'rounded-md', 'uppercase', 'px-2', 'py-1', 'text-xs', 'font-bold', 'text-white', 'block', 'text-center', 'truncate']

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
