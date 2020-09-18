<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
      <VueTrix v-model="editorContent" :placeholder="field.placeholder" class="prose prose-sm" inputId="trixEditor"/>
  </edit-field-wrapper>
</template>

<style scoped>
.trix-content pre {
  background-color: #2D3478 !important;
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
