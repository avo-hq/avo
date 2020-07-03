<template>
  <index-field-wrapper :field="field" class="text-center">
    <div v-if="value" v-text="value"></div>
    <empty-dash v-else />
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
