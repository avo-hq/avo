<template>
  <tr>
    <td class="w-4/9 text-left py-3 px-4">
      <input
        type="textarea"
        :value="mapKey"
        :id="mapKey"
        :disabled="disabled"
        :style="disableEditingKeys ? 'cursor: not-allowed;' : ''"
        @change="updateKey(mapKey, value, $event)"
      />
    </td>
    <td class="w-4/9 text-left py-3 px-4">
      <input
        type="textarea"
        :value="value"
        :disabled="disabled"
        @change="updateValue(mapKey, $event)"
        @keyup.enter="addRow"
      />
    </td>
    <td class="w-1/9 text-left py-3 px-4 float-right">
      <a
        href="javascript:void(0);"
        @click="deleteRow(mapKey)"
        v-tooltip="deleteText"
        :style="disableDeletingRows ? 'cursor: not-allowed;' : ''"
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
    mapKey: String,
    value: String,
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
    }
  },
  methods: {
    // getValue() {
    //   // console.log(this.value)
    //   // console.log(JSON.stringify(this.value))
    //   // TODO prevent saving empty key or value values (when saving will work)
    //   return this.value
    // },
    // updateKey(oldKey, val, e) {
    //   const newKey = e.target.value
    //   this.$set(this.value, newKey, val)
    //   this.$delete(this.value, oldKey)
    // },
    updateValue(key, e) {
      const newValue = e.target.value
      this.$set(this.value, key, newValue)
      this.$emit('valueUpdated', this.key, newValue)
    },
    // deleteRow(key) {
    //   if (!this.field.disable_deleting_rows) this.$delete(this.value, key)
    // },
    // addRow() {
    //   if (!this.field.disable_adding_rows) {
    //     this.$set(this.value, '', '')
    //   }
    // },
  },
}
</script>
