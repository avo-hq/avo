<template>
  <index-field-wrapper :field="field" class="text-center">
    <component :is="component"
      v-if="component"
      :class="classes"
    />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
  computed: {
    classes() {
      let classes = 'h-6'

      if (this.field.value) {
        classes += ' text-green-600'
      } else {
        classes += ' text-red-600'
      }

      return classes
    },
    component() {
      if (this.field.value) return 'check-circle-icon'

      return 'x-circle-icon'
    },
  },
}
</script>
