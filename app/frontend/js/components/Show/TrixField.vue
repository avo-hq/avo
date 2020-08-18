<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <div v-if="field.value">
      <div v-if="showTrix" v-html="field.value" :style="styles"/>
      <a href="javascript:void(0);" v-if="!field.always_show" @click="toggleTrix">
        {{showTrix===true ? 'Hide Trix' : 'Show Trix'}}
      </a>
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
    styles() {
      let styles = 'border: 1px solid #bbb; border-radius: 3px; margin: 0; padding: 0.4em 0.6em; min-height: 5em; outline: none;'

      if (!this.field.always_show) styles += ' margin-bottom: 0.8em;'

      return styles
    },
  },
  methods: {
    toggleTrix() {
      this.showTrix = !this.showTrix
    },
  },
}
</script>
