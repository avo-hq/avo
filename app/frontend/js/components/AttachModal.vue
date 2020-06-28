<template>
  <div class="w-full h-full flex flex-col justify-between">
    <div class="p-4 text-xl" v-if="heading">
      {{ heading }}
    </div>
    <div class="flex-1 flex flex-col items-center justify-center px-24 text-lg">
      {{ text }}
      <select name="options"
        id="options"
        :class="inputClasses"
        class="select-input w-full mt-4"
        v-model="selectedOption"
      >
        <option value="">Choose one</option>
        <option v-for="option in options"
          :key="option.value"
          :value="option.value"
          v-text="option.label"
          ></option>
      </select>
    </div>
    <div class="flex justify-end space-x-4 p-4 bg-gray-200">
      <button
        ref="attach-button"
        class="button border-green-700 text-green-700"
        v-if="attachAction"
        @click="attachOption(selectedOption)"
      >
        Attach
      </button>
      <button
        ref="attach-another-button"
        class="button border-green-700 text-green-700"
        v-if="attachAction"
        @click="attachOption(selectedOption, true)"
      >
        Attach &amp; Attach another
      </button>
      <button class="button"
        ref="cancel-button"
        v-if="attachAction"
        @click="$emit('close')"
      >
        Cancel
      </button>
    </div>
  </div>
</template>

<script>
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [HasInputAppearance],
  data: () => ({
    options: [],
    selectedOption: '',
  }),
  props: [
    'heading',
    'text',
    'attachAction',
    'getOptions',
  ],
  methods: {
    attachOption(option, attachAnother = false) {
      this.attachAction(option, attachAnother)

      if (attachAnother) {
        this.selectedOption = ''
      }
    },
  },
  async mounted() {
    this.options = await this.getOptions()
    this.$refs['attach-button'].focus()
  },
}
</script>
