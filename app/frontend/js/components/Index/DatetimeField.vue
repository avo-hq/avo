<template>
  <index-field-wrapper :field="field">
    <div v-if="value" v-text="value"/>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import moment from 'moment'

export default {
  data: () => ({}),
  props: ['field'],
  computed: {
    value() {
      if (this.field.value) return moment(new Date(this.field.value)).format(this.field.format)

      return null
    },
  },
  methods: {},
  mounted() {},
}
</script>
