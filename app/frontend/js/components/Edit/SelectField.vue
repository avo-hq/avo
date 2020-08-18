<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
    >
      <option v-if="!value" :value="value" v-text="field.placeholder" disabled selected hidden/>
      <option v-for="(option, key) in field.options"
        :value="key"
        :key="key"
        v-text="(!field.display_value && option) ? option : key"
      />
    </select>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [FormField, HasInputAppearance],
}
</script>
