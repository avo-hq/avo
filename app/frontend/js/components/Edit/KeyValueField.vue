<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div class="shadow overflow-hidden rounded" v-if="value">
      <table class="min-w-full bg-white">
        <thead class="bg-gray-800 text-white">
          <tr>
            <th class="w-4/9 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ field.key_label }}
            </th>
            <th class="w-4/9 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ field.value_label }}
            </th>
            <th class="w-1/9 text-left py-3 px-4 float-right">
              <a href="javascript:void(0);"
                @click="addRow"
                v-tooltip="field.action_text"
                :style="field.disable_adding_rows ? 'cursor: not-allowed;' : ''"
              ><PlusIcon class="text-gray-400 h-6 hover:text-gray-500"
              /></a>
            </th>
          </tr>
        </thead>
        <tbody class="text-gray-700">
          <tr v-for="(val, key, index) in value" v-bind:key="index">
            <td class="w-4/9 text-left py-3 px-4">
              <input
                type="text"
                :value="key"
                :disabled="field.disable_editing_keys"
                :style="field.disable_editing_keys ? 'cursor: not-allowed;' : ''"
                @change="updateKey(key, val, $event)"
              />
            </td>
            <td class="w-4/9 text-left py-3 px-4">
              <input
                type="text"
                :value="val"
                :disabled="disabled"
                @change="updateValue(key, $event)"
              />
            </td>
            <td class="w-1/9 text-left py-3 px-4 float-right">
              <a href="javascript:void(0);"
                @click="deleteRow(key)"
                v-tooltip="field.delete_text"
                :style="field.disable_deleting_rows ? 'cursor: not-allowed;' : ''"
                ><DeleteIcon class="text-gray-400 h-6 hover:text-gray-500"
              /></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
/* eslint-disable import/no-unresolved */
import DeleteIcon from '@/svgs/trash.svg?inline'
import PlusIcon from '@/svgs/plus.svg?inline'

export default {
  mixins: [FormField],
  components: {
    DeleteIcon, PlusIcon,
  },
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = JSON.parse(this.field.value)
      } else {
        this.value = {}
      }
    },
    getValue() {
      // console.log(this.value)
      // console.log(JSON.stringify(this.value))
      // TODO prevent saving empty key or value values (when saving will work)
      return JSON.stringify(this.value)
    },
    updateKey(oldKey, val, e) {
      const newKey = e.target.value
      this.$set(this.value, newKey, val)
      this.$delete(this.value, oldKey)
    },
    updateValue(key, e) {
      const newValue = e.target.value
      this.$set(this.value, key, newValue)
    },
    deleteRow(key) {
      if (!this.field.disable_deleting_rows) this.$delete(this.value, key)
    },
    addRow() {
      if (!this.field.disable_adding_rows) this.$set(this.value, '', '')
    },
  },
}
</script>
