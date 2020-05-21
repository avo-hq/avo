<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <select v-model="value">
      <option v-for="(option, key) in field.options" :value="key" :key="key">
        {{option}}
      </option>
    </select>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
}
</script>
