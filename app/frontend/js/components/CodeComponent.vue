<template>
    <codemirror
      v-if="value || editable"
      v-model="valueInput"
      :options="cmOptions"
      class="rounded-lg overflow-hidden"
      :style="heightStyle"
    />
    <empty-dash v-else />
</template>

<script>
/* eslint-disable import/no-extraneous-dependencies */
import { codemirror } from 'vue-codemirror'

import 'codemirror/lib/codemirror.css'

// themes
import 'codemirror/theme/dracula.css'
import 'codemirror/theme/eclipse.css'
import 'codemirror/theme/material-darker.css'

// programming_languages
import 'codemirror/mode/css/css'
import 'codemirror/mode/dockerfile/dockerfile'
import 'codemirror/mode/htmlmixed/htmlmixed'
import 'codemirror/mode/javascript/javascript'
import 'codemirror/mode/markdown/markdown'
import 'codemirror/mode/nginx/nginx'
import 'codemirror/mode/php/php'
import 'codemirror/mode/ruby/ruby'
import 'codemirror/mode/sass/sass'
import 'codemirror/mode/shell/shell'
import 'codemirror/mode/sql/sql'
import 'codemirror/mode/vue/vue'
import 'codemirror/mode/xml/xml'

export default {
  components: { codemirror },
  props: {
    value: String,
    language: String,
    theme: String,
    editable: Boolean,
    height: String,
  },
  computed: {
    heightStyle() {
      return {
        '--height': this.height,
      }
    },
    cmOptions() {
      return {
        readOnly: !this.editable,
        mode: this.language,
        theme: this.theme,
        tabSize: 4,
        indentWithTabs: true,
        lineNumbers: true,
        lineWrapping: true,
      }
    },
    valueInput: {
      get() {
        if (this.value == null) return ''

        return this.value
      },
      set(newVal) {
        this.$emit('value-updated', newVal)
      },
    },
  },
}
</script>

<style>
.CodeMirror {
  height: var(--height) !important;
}
</style>
