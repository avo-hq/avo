<template>
  <field-wrapper :field="field">
      <input type="text"
        v-model="value"
      >
  </field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field.js'

export default {
  mixins: [FormField],
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {},
}
</script>

<style lang="postcss"></style>
