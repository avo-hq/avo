<template>
  <show-field-wrapper :field="field" :errors="errors" :index="index">
      <input type="text"
        v-model="value"
        disabled
      >
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {},
}
</script>

<style lang="postcss"></style>
