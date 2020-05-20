<template>
  <show-field-wrapper :field="field" :index="index">
    {{value}}
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    value() {
      if (this.field.value) return '✅'

      return '❌'
    },
  },
}
</script>
