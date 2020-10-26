<template>
  <div :class="classes" v-if="field">
    <div class="w-48 md:w-64 p-4 px-6 h-full flex" data-slot="label">
      <slot name="label">
        {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
      </slot>
    </div>
    <div class="flex-1 flex flex-row">
      <div :class="valueSlotClasses" data-slot="value">
        <slot />
      </div>
      <div class="flex-1 py-4" v-if="!valueSlotFullWidth" data-slot="extra">
        <slot name="extra" />
      </div>
    </div>
  </div>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import IsFieldWrapper from '@/js/mixins/is-field-wrapper'

export default {
  mixins: [IsFormField, IsFieldWrapper],
  props: ['field', 'index', 'valueSlotFullWidth'],
}
</script>
