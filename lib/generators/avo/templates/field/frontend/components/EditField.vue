<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" v-model="value" />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  data: () => ({
    value: '',
  }),
  mixins: [FormField],
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
