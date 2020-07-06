<template>
  <show-field-wrapper :field="field" :index="index">
    <StatusComponent
      v-if="field.value"
      :status="status"
      :label="field.value"
    />
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import IsStatusField from '@/js/mixins/is-status-field'
import StatusComponent from '@/js/components/StatusComponent.vue'

export default {
  props: ['field', 'index'],
  components: { StatusComponent },
  mixins: [IsStatusField],
}
</script>
