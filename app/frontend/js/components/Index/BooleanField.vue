<template>
  <index-field-wrapper :field="field" class="text-center">
    {{value}}
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
  computed: {
    value() {
      if (this.field.value) return '✅'

      return '❌'
    },
  },
}
</script>
