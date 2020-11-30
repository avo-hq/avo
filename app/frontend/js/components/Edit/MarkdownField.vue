<template>
  <edit-field-wrapper
    :field="field"
    :errors="errors"
    :index="index"
    :displayed-in="displayedIn"
    :value-slot-full-width="true"
  >
    <mavon-editor
      ref="md"
      class="break-all"
      v-model="value"
      :placeholder="field.placeholder"
      language="en"
      :toolbars="toolbars"
      default-open="edit"
      :style="{height: field.height}"
      :autofocus="false"
    />
  </edit-field-wrapper>
</template>

<script>
import 'mavon-editor/dist/css/index.css'
import { IsFormField } from '@avo-hq/avo-js'
import { mavonEditor } from 'mavon-editor'

export default {
  mixins: [IsFormField],
  components: {
    mavonEditor,
  },
  data() {
    return {
      toolbars: {
        bold: true,  // bold
        italic: true,  // italic
        header: true,  // title
        underline: true,  // underline
        strikethrough: true,  // underline
        mark: true,  // mark
        superscript: true,  // superscript
        subscript: true,  // subscript
        quote: true,  // quote
        ol: true,  // ordered list
        ul: true,  // unordered list
        link: true,  // link
        imagelink: false,  // Picture link
        code: true,  // code
        table: true,  // table
        fullscreen: true,  // full screen editing
        readmodel: false, // immersive reading
        htmlcode: true,  // display html source code
        help: true,  // help
        /* 1.3.5 */
        undo: true,  // previous step
        redo: true,  // next step
        trash: true,  // Clear
        save: false,  // save (trigger the save event in events)
        /* 1.4.2 */
        navigation: false,  // navigation directory
        /* 2.1.8 */
        alignleft: true,  // left alignment
        aligncenter: true, // center
        alignright: true,  // right align
        /* 2.2.1 */
        subfield: true,  // single and double column mode
        preview: true,  // preview
      },
    }
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
