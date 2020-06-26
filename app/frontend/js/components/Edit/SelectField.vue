<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
    >
      <option value="null" disabled>{{field.placeholder}}</option>
      <option v-for="(option, key) in field.options" :value="key" :key="key">
        {{option}}
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
}
</script>
