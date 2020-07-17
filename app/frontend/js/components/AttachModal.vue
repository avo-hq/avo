<template>
  <div class="w-full h-full flex flex-col justify-between">
    <div class="p-4 text-xl" v-if="heading">
      {{ heading }}
    </div>
    <div class="flex-1 flex flex-col items-center justify-center px-24 text-lg">
      {{ text }}
      <select name="options"
        ref="select"
        id="options"
        :class="inputClasses"
        class="select-input w-full mt-4"
        v-model="selectedOption"
        @keyup.enter="attachOption"
      >
        <option value="">Choose one</option>
        <option v-for="option in options"
          :key="option.value"
          :value="option.value"
          v-text="option.label"
        />
      </select>
    </div>
    <div class="flex justify-end space-x-4 p-4 bg-gray-200">
      <a-button
        ref="attach-button"
        color="green"
        v-if="attachAction"
        :disabled="nothingSelected"
        @click="attachOption"
      >
        Attach
      </a-button>
      <a-button
        ref="attach-another-button"
        color="green"
        variant="outlined"
        v-if="attachAction"
        :disabled="nothingSelected"
        @click="attachOption(true)"
      >
        Attach &amp; Attach another
      </a-button>
      <a-button
        ref="cancel-button"
        v-if="attachAction"
        @click="$emit('close')"
      >
        Cancel
      </a-button>
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
  computed: {
    nothingSelected() {
      return this.selectedOption === ''
    },
  },
  methods: {
    attachOption(attachAnother = false) {
      this.attachAction(this.selectedOption, attachAnother)

      if (attachAnother) {
        this.selectedOption = ''
      }
    },
  },
  async mounted() {
    this.options = await this.getOptions()
    this.$refs.select.focus()
  },
}
</script>
