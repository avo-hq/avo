<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="value" v-text="value"></div>
    <empty-dash v-else />
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
