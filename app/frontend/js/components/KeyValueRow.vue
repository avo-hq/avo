<template>
  <div class="flex -mb-px">
      <input-component
        class="-mr-px"
        :class="inputClasses"
        ref="keyInput"
        :value="loopKey"
        :placeholder="keyLabel"
        :disabled="readOnly"
        @input="updateKey"
      />
      <input-component
        :class="inputClasses"
        :value="loopValue"
        :placeholder="valueLabel"
        :disabled="readOnly"
        @input="updateValue"
        @keyup.native.enter="$emit('keyup-enter')"
      />
    <div class="flex items-center justify-center px-2" v-if="!readOnly">
      <a
        href="javascript:void(0);"
        @click="$emit('delete-row', index)"
        v-tooltip="deleteText"
        :class="{'cursor-not-allowed': disableDeletingRows}"
      >
        <DeleteIcon class="text-gray-400 h-5 hover:text-gray-500" />
      </a>
    </div>
  </div>

</template>

<script>
/* eslint-disable import/no-unresolved */
import DeleteIcon from '@/svgs/trash.svg?inline'

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
  components: {
    DeleteIcon,
  },
  computed: {
    disabled() {
      if (this.disableEditingKeys) return true

      return this.readOnly
    },
    inputClasses() {
      return 'w-1/2 text-left flex rounded-b-none rounded-t-none focus:bg-gray-200 border-gray-500 relative'
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
      console.log('focuss')
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
