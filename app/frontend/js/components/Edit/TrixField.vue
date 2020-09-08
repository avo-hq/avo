<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
      <VueTrix v-model="editorContent" :placeholder="field.placeholder"/>
  </edit-field-wrapper>
</template>

<style>
ul {
  list-style-position: initial !important;
  list-style-image: initial !important;
  list-style-type: disc !important;
}

ol {
  list-style-position: initial !important;
  list-style-image: initial !important;
  list-style-type: decimal !important;
}
</style>

<script>
import FormField from '@/js/mixins/form-field'
import VueTrix from 'vue-trix'

export default {
  mixins: [FormField],
  components: {
    VueTrix,
  },
  data() {
    return {
      editorContent: this.field.value,
    }
  },
  computed: {},
  methods: {
    setInitialValue() {
      this.editorContent = this.field.value
    },
    getValue() {
      return this.editorContent
    },
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
