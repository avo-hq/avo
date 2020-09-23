<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <div v-if="field.value">
      <div v-if="showTrix" v-html="field.value" class="prose prose-sm"/>
      <a href="javascript:void(0);"
        v-if="!field.always_show"
        :class="buttonStyle"
        @click="toggleTrix"
        v-text="linkLabel"
      />
    </div>
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  data() {
    return {
      showTrix: this.field.always_show,
    }
  },
  computed: {
    buttonStyle() {
      if (this.showTrix) return 'font-bold inline-block mt-6'

      return 'font-bold'
    },
    linkLabel() {
      return this.showTrix ? 'Hide Content' : 'Show Content'
    },
  },
  methods: {
    toggleTrix() {
      this.showTrix = !this.showTrix
    },
  },
}
</script>

<style>
.prose {
  max-width: none !important;
}
</style>
