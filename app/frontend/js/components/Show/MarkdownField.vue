<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <div v-if="field.value">
      <mavon-editor
        v-if="showContent"
        ref="md"
        :value="field.value"
        :subfield = "false"
        :defaultOpen = "'preview'"
        :toolbarsFlag = "false"
        :editable="false"
        :scrollStyle="true"
        :ishljs = "true"
        language="en"
        codeStyle="dracula"
      ></mavon-editor>
      <a href="javascript:void(0);"
        v-if="!field.always_show"
        :class="buttonStyle"
        @click="toggleContent">
        {{showContent===true ? 'Hide Content' : 'Show Content'}}
      </a>
    </div>
    <empty-dash v-else />
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
