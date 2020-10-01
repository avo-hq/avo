<template>
  <edit-field-wrapper
    :field="field"
    :errors="errors"
    :index="index"
    :displayed-in="displayedIn"
    :value-slot-full-width="true"
  >
    <button
      class="inline-flex flex-grow-0 items-center font-bold text-sm leading-none fill-current whitespace-no-wrap transition duration-100 rounded-lg shadow-xl transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer text-white bg-gray-500 hover:bg-gray-600 p-3 mb-2"
      :class="{'bg-gray-600 font-extrabold': this.mode == 'write',}"
      @click.prevent="write()"
    >
      Write
    </button>
    <button
      class="inline-flex flex-grow-0 items-center font-bold text-sm leading-none fill-current whitespace-no-wrap transition duration-100 rounded-lg shadow-xl transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer text-white bg-green-500 hover:bg-green-600 p-3 mb-2"
      :class="{'bg-green-600 font-extrabold': this.mode == 'preview',}"
      @click.prevent="preview()"
    >
      Preview
    </button>

    <div v-show="this.mode == 'write'">
      <input-component
        ref="field-input"
        type="textarea"
        class="w-full"
        :id="field.id"
        :disabled="disabled"
        :rows="rows"
        :placeholder="field.placeholder"
        v-model="value"
      />
    </div>

    <div
      v-show="this.mode == 'preview'"
      class="prose prose-sm markdown leading-normal"
      v-html="this.previewContent"
    ></div>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

const md = require('markdown-it')()

export default {
  mixins: [FormField],

  data: () => ({
    mode: 'write',
    previewContent: '',
  }),
  computed: {
    rows() {
      return this.field.rows || 5
    },
  },
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
    write() {
      this.mode = 'write'
    },
    preview() {
      this.mode = 'preview'
      this.previewContent = md.render(this.value)
    },
  },
}
</script>

<style>
.prose {
  max-width: none !important;
}
</style>
