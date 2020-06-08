<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <select class="select-input w-full"
      :class="inputClasses"
      v-model="value"
    >
      <option v-for="(option, key) in field.options" :value="key" :key="key">
        {{option}}
      </option>
      <option v-if="!value" value="" disabled selected>{{field.placeholder}}</option>
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
