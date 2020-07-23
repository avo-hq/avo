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
import { IsFormField } from '@AvocadoHQ/avocado-js'
import CodeComponent from '@/js/components/CodeComponent.vue'

export default {
  mixins: [IsFormField],
  components: { CodeComponent },
  methods: {
    valueUpdated(newVal) {
      this.value = newVal
    },
  },
}
</script>
