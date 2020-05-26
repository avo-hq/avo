<template>
  <index-field-wrapper :field="field">
    {{value}}
  </index-field-wrapper>
</template>

<script>
import moment from 'moment'

export default {
  data: () => ({}),
  props: ['field'],
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
