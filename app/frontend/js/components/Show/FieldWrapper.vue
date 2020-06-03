<template>
  <div :class="classes" v-if="field">
    <div class="w-48 md:w-64 p-4 h-full flex" data-slot="label">
      <slot name="label">
        {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
      </slot>
    </div>
    <div class="flex-1 flex flex-row">
      <div :class="valueSlotClasses" data-slot="value">
        <slot />
      </div>
      <div class="flex-1 py-4 flex" v-if="!valueSlotFullWidth" data-slot="extra">
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
  props: ['field', 'index', 'valueSlotFullWidth'],
}
</script>
