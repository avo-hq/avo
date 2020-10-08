<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <KeyValue
      v-if="value"
      v-model="value"
      :key-label="field.key_label"
      :value-label="field.value_label"
      :read-only="true"
      :action-text="field.action_text"
      :delete-text="field.delete_text"
      :disable-editing-keys="field.disable_editing_keys"
      :disable-adding-rows="field.disable_adding_rows"
      :disable-deleting-rows="field.disable_deleting_rows"
    />
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import KeyValue from '@/js/components/KeyValueComponent.vue'

export default {
  mixins: [IsFormField],
  components: { KeyValue },
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = this.field.value
      }
    },
  },
}
</script>
