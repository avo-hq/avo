<template>
<edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
  <div class="h-8 flex items-center">
    <input type="checkbox"
      ref="field-input"
      :id="field.id"
      :disabled="disabled"
      class="w-4 h-4"
      v-model="value"
    >
  </div>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  methods: {
    getValue() {
      switch (this.value) {
        case true:
          return this.field.true_value
        default:
        case false:
          return this.field.false_value
      }
    },
  },
}
</script>
