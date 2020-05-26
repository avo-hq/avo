<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-text="value"></div>
  </show-field-wrapper>
</template>

<script>
import moment from 'moment'

export default {
  data: () => ({}),
  props: ['field', 'index'],
  computed: {
    value() {
      if (this.field.value) return moment(this.field.value).format(this.field.format)
      return '-'
    },
  },
  methods: {},
  mounted() {},
}
</script>

