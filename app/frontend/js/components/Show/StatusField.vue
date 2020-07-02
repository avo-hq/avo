<template>
  <show-field-wrapper :field="field" :index="index">
    <StatusComponent
      v-if="value"
      :status="status"
      :label="value"
      >
    </StatusComponent>
    <div v-else>
      -
    </div>
  </show-field-wrapper>
</template>

<script>
/* eslint-disable import/no-unresolved */
import StatusComponent from '@/js/components/StatusComponent'

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
    value() {
      return this.field.value
    },
  },
}
</script>
