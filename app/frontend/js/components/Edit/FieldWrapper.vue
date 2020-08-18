<template>
  <div :class="classes" v-if="field">
    <div :class="labelClasses">
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
      <div class="flex-1 py-4" v-if="extraSlotVisible" data-slot="extra">
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
  props: {
    field: {},
    index: {},
    errors: {},
    valueSlotFullWidth: {},
    displayedIn: {
      default: () => 'form',
    },
  },
  computed: {
    extraSlotVisible() {
      return !this.valueSlotFullWidth && !this.displayedInModal
    },
    displayedInModal() {
      return this.displayedIn === 'modal'
    },
    labelClasses() {
      if (this.displayedInModal) {
        return 'w-48 md:w-48 p-4 px-8 h-full flex'
      }

      return 'w-48 md:w-64 p-4 px-8 h-full flex'
    },
  },
}
</script>
