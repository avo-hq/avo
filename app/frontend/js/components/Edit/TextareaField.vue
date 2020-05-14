<template>
  <show-field-wrapper :field="field">
    <textarea
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
  computed: {},
  methods: {},
}
</script>

<style lang="postcss"></style>
