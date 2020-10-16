<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <input-component
      ref="field-input"
      type="textarea"
      class="w-full"
      :id="field.id"
      :disabled="disabled"
      :rows="rows"
      :placeholder="field.placeholder"
      v-model="value"
      />
  </edit-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'

export default {
  mixins: [IsFormField],
  computed: {
    rows() {
      return this.field.rows || 5
    },
  },
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
