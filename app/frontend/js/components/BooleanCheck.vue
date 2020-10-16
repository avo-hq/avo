<template>
  <component :is="component" :class="classes" :data-checked="checked ? 1 : 0" />
</template>

<script>
export default {
  props: {
    checked: Boolean,
  },
  computed: {
    classes() {
      let classes = 'h-5 float-left'

      if (this.checked) {
        classes += ' text-green-600'
      } else {
        classes += ' text-red-600'
      }

      return classes
    },
    component() {
      if (this.checked) return 'check-circle-icon'

      return 'x-circle-icon'
    },
  },
}
</script>
