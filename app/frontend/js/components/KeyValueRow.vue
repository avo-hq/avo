<template>
  <tr>
    <td class="w-4/9 text-left py-3 px-4">
      <input-component
        ref="keyInput"
        :value="loopKey"
        @input="updateKey"
      />
    </td>
    <td class="w-4/9 text-left py-3 px-4">
      <input-component
        :value="loopValue"
        @input="updateValue"
        @keyup.native.enter="$emit('keyup-enter')"
      />
    </td>
    <td class="w-1/9 text-left py-3 px-4 float-right">
      <a
        href="javascript:void(0);"
        @click="$emit('delete-row', index)"
        v-tooltip="deleteText"
        :class="{'cursor-not-allowed': disableDeletingRows}"
      >
        <DeleteIcon class="text-gray-400 h-6 hover:text-gray-500" />
      </a>
    </td>
  </tr>

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
      this.$refs.keyInput.focus()
    },
  },
}
</script>
