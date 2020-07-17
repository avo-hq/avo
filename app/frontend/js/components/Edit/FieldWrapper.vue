<template>
  <div :class="classes" v-if="field">
    <div class="w-48 md:w-64 p-4 px-8 h-full flex">
      <slot name="label" data-slot="label">
        <label :for="field.id" class="py-2">
          {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
        </label>
      </slot>
    </div>
    <div class="flex-1 flex flex-row pr-8">
      <div :class="valueSlotClasses" data-slot="value">
        <slot />
        <div class="text-gray-600 mt-2" v-if="field.help" v-html="field.help"></div>
        <div class="text-red-600 mt-2" v-if="fieldError" v-text="fieldError"></div>
      </div>
      <div class="flex-1 py-4" v-if="!valueSlotFullWidth" data-slot="extra">
        <slot name="extra" />
      </div>
    </div>
  </div>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import IsFieldWrapper from '@/js/mixins/is-field-wrapper'

export default {
  mixins: [FormField, IsFieldWrapper],
  props: ['field', 'index', 'errors', 'valueSlotFullWidth'],
}
</script>
