<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
    <codemirror v-model="value" :options="cmOptions" />
  </edit-field-wrapper>
</template>

<script>
/* eslint-disable import/no-extraneous-dependencies */
import FormField from '@/js/mixins/form-field'

import { codemirror } from 'vue-codemirror'

import 'codemirror/lib/codemirror.css'

// themes
import 'codemirror/theme/dracula.css'
import 'codemirror/theme/eclipse.css'
import 'codemirror/theme/material-darker.css'

// programming_languages
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
import 'codemirror/mode/yaml/yaml'

export default {
  mixins: [FormField],
  components: { codemirror },
  computed: {
    cmOptions() {
      return {
        mode: this.language,
        theme: this.theme,
        tabSize: 4,
        indentWithTabs: true,
        lineNumbers: true,
        lineWrapping: true,
      }
    },
    language() {
      return this.field.language
    },
    theme() {
      return this.field.theme
    },
  },
}
</script>
