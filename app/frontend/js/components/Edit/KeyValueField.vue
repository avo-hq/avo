<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn" :value-slot-full-width="true">
    <KeyValue
      v-model="value"
      :key-label="field.key_label"
      :value-label="field.value_label"
      :read-only="false"
      :action-text="field.action_text"
      :delete-text="field.delete_text"
      :disable-editing-keys="field.disable_editing_keys"
      :disable-adding-rows="field.disable_adding_rows"
      :disable-deleting-rows="field.disable_deleting_rows"
    />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import KeyValue from '@/js/components/KeyValueComponent.vue'
import pickBy from 'lodash/pickBy'

export default {
  mixins: [FormField],
  components: { KeyValue },
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = this.field.value
      } else {
        this.value = {}
      }
    },
    getValue() {
      if (Object.keys(this.value).length === 0) {
        return ''
      }

      return pickBy(this.value, (value, key) => key !== '')
    },
  },
}
</script>
