<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
      :id="field.id"
    >
      <option value="null" disabled>{{field.placeholder}}</option>
      <option v-for="(name, code) in countries" :value="code" :key="code">
        {{name}}
      </option>
    </select>
  </edit-field-wrapper>
</template>

<script>
/* eslint-disable max-len */
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [FormField, HasInputAppearance],
  computed: {
    countries() {
      return this.field.countries
    },
  },
}
</script>
