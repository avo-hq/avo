<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
    >
      <option v-if="!value" :value="value" v-text="field.placeholder" disabled/>
      <option v-for="(label, value) in field.options"
        :value="value"
        :key="value"
        v-text="optionLabel(label, value)"
      />
    </select>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [FormField, HasInputAppearance],
  methods: {
    optionLabel(label, value) {
      if (this.field.display_value) return value

      return label
    },
  },
}
</script>
