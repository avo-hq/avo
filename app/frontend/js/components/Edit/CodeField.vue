<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
    <code-component
      :value="value"
      :language="field.language"
      :theme="field.theme"
      :editable="true"
      @value-updated="valueUpdated"
    />
  </edit-field-wrapper>
</template>

<script>
import CodeComponent from '@/js/components/CodeComponent.vue'
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  components: { CodeComponent },
  methods: {
    valueUpdated(newVal) {
      this.value = newVal
    },
  },
}
</script>
