<template>
  <div class="flex -mb-px">
    <input-component
      :class="inputClasses"
      class="border-gray-600 border-r border-l-0 border-b-0 border-t-0 focus:border-gray-700"
      ref="keyInput"
      :value="loopKey"
      :placeholder="keyLabel"
      :disabled="readOnly || disableEditingKeys"
      @input="updateKey"
      @keydown.native.enter.prevent=""
    />
    <input-component
      :class="inputClasses"
      class="border-none"
      :value="loopValue"
      :placeholder="valueLabel"
      :disabled="readOnly"
      @input="updateValue"
      @keyup.native.enter="$emit('keyup-enter')"
      @keydown.native.enter.prevent=""
    />
    <div class="flex items-center justify-center px-3 bg-gray-200 border-l border-gray-600" v-if="!readOnly">
      <a
        href="javascript:void(0);"
        @click="$emit('delete-row', index)"
        v-tooltip="deleteText"
        data-button="delete-row"
        :class="{'cursor-not-allowed': disableDeletingRows}"
      ><trash-icon class="text-gray-500 h-5 hover:text-gray-500" /></a>
    </div>
  </div>

</template>

<script>
export default {
  props: {
    loopKey: String,
    loopValue: String,
    index: Number,
    readOnly: Boolean,
    deleteText: String,
    keyLabel: String,
    valueLabel: String,
    disableEditingKeys: Boolean,
    disableDeletingRows: Boolean,
  },
  computed: {
    disabled() {
      if (this.disableEditingKeys) return true

      return this.readOnly
    },
    inputClasses() {
      return 'w-1/2 text-left flex rounded-b-none rounded-t-none focus:bg-gray-400 relative outline-none'
    },
  },
  methods: {
    updateValue(value) {
      this.$emit('value-updated', {
        index: this.index,
        value,
      })
    },
    updateKey(value) {
      this.$emit('key-updated', {
        index: this.index,
        value,
      })
    },
    focus() {
      this.$refs.keyInput.$el.focus()
    },
  },
  mounted() {
    this.$on('focus', this.focus)
  },
  destroyed() {
    this.$off('focus')
  },
}
</script>

<style>
.-mb-px {
  margin-bottom: -1px;
}
.-mr-px {
  margin-right: -1px;
}
</style>
