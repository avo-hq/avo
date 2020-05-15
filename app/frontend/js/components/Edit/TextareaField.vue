<template>
  <show-field-wrapper :field="field">
    <textarea
      :rows="rows"
      class="w-full"
      v-model="value"
    ></textarea>
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  props: ['field'],
  computed: {
    rows() {
      return this.field.rows || 5
    },
  },
  methods: {},
}
</script>

<style lang="postcss"></style>
