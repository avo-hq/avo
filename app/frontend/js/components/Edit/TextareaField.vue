<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
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
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
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
