<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
      <VueTrix v-model="value" :placeholder="field.placeholder" localStorage/>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import VueTrix from 'vue-trix'

export default {
  mixins: [FormField],
  components: {
    VueTrix,
  },
  computed: {},
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
