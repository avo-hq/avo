<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input-component
      type="textarea"
      class="w-full"
      :id="field.id"
      :disabled="disabled"
      :rows="rows"
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
}
</script>
