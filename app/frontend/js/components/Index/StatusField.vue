<template>
  <index-field-wrapper :field="field">
    <StatusComponent
      v-if="field.value"
      :status="status"
      :label="field.value"
    />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import IsStatusField from '@/js/mixins/is-status-field'
import StatusComponent from '@/js/components/StatusComponent.vue'

export default {
  props: ['field'],
  components: { StatusComponent },
  mixins: [IsStatusField],
}
</script>
