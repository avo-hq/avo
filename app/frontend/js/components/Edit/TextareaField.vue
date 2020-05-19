<template>
  <show-field-wrapper :field="field" :errors="errors" :index="index">
    <textarea
      :rows="rows"
      :disabled="disabled"
      v-model="value"
      class="w-full"
    ></textarea>
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  computed: {
    rows() {
      return this.field.rows || 5
    },
  },
  methods: {},
}
</script>

<style lang="postcss"></style>
