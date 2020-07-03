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
import StatusComponent from '@/js/components/StatusComponent.vue'

export default {
  props: ['field', 'index'],
  components: { StatusComponent },
  computed: {
    status() {
      if (this.isFailing) return 'fail'
      if (this.isLoading) return 'load'

      return 'success'
    },
    isFailing() {
      return this.field.failed_when.indexOf(this.field.value) > -1
    },
    isLoading() {
      return this.field.loading_when.indexOf(this.field.value) > -1
    },
  },
}
</script>
