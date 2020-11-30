<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <mavon-editor
      v-if="field.value && (field.always_show || showContent)"
      ref="md"
      :value="field.value"
      :subfield="false"
      :defaultOpen="'preview'"
      :toolbarsFlag="false"
      :editable="false"
      :scrollStyle="true"
      :ishljs="true"
      language="en"
    />
    <a href="javascript:void(0);"
      v-if="!field.always_show && field.value"
      :class="buttonStyle"
      @click="toggleContent"
      v-text="showHideLabel"
    />
    <empty-dash v-if="!field.value" />
  </show-field-wrapper>
</template>

<script>
import 'mavon-editor/dist/css/index.css'
import { mavonEditor } from 'mavon-editor'

export default {
  props: ['field', 'index'],
  components: {
    mavonEditor,
  },
  data() {
    return {
      showContent: this.field.always_show,
    }
  },
  computed: {
    buttonStyle() {
      if (this.showContent) return 'font-bold inline-block mt-6'

      return 'font-bold'
    },
    showHideLabel() {
      if (this.showContent) return 'Hide Content'

      return 'Show Content'
    },
  },
  methods: {
    toggleContent() {
      this.showContent = !this.showContent
    },
  },
}
</script>

<style>
.markdown-body ul {
  @apply list-disc;
}
.markdown-body ol {
  @apply list-decimal;
}
</style>
