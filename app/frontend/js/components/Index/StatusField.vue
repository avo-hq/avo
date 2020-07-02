<template>
  <index-field-wrapper :field="field">
    <StatusComponent
      v-if="value"
      :status="status"
      :label="value"
    />
    <div v-else>
      -
    </div>
  </index-field-wrapper>
</template>

<script>
/* eslint-disable import/no-unresolved */
import StatusComponent from '@/js/components/StatusComponent'

export default {
  props: ['field'],
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
