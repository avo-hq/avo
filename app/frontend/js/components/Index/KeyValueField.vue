<template>
  <index-field-wrapper :field="field" class="text-center">
    <KeyValue
      v-if="isVisible"
      :db-value="value"
      :key-label="field.key_label"
      :value-label="field.value_label"
      :read-only=true
      :action-text="field.action_text"
      :delete-text="field.delete_text"
      :disable-editing-keys="field.disable_editing_keys"
      :disable-adding-rows="field.disable_adding_rows"
      :disable-deleting-rows="field.disable_deleting_rows"
      >
    </KeyValue>
    <button @click="toggleView" v-else>
      View
    </button>
  </index-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
/* eslint-disable import/no-unresolved */
import KeyValue from '@/js/components/KeyValue'

export default {
  mixins: [FormField],
  components: { KeyValue },
  data: () => ({
    isVisible: false,
  }),
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = this.field.value
      }
    },
    toggleView() {
      this.isVisible = true
    },
  },
}
</script>
