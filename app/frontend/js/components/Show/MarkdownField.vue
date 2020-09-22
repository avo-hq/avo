<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <div v-if="field.value">
      <div v-if="showContent" v-html="content" class="prose prose-sm markdown leading-normal"/>
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

<style>
.prose {
  max-width: none !important;
}
</style>

<script>
const md = require('markdown-it')()

export default {
  props: ['field', 'index'],
  data() {
    return {
      showContent: this.field.always_show,
    }
  },
  computed: {
    content() {
      return md.render(this.field.value || '')
    },
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
