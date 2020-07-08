<template>
  <div class="w-full" v-if="value">
    <div class="w-full flex flex-col">
      <div class="flex w-full">
        <div class="flex w-full bg-gray-800 shadow overflow-hidden rounded-t">
          <div class="w-1/2 py-3 px-4 uppercase font-semibold text-sm text-white">
            {{ keyLabel }}
          </div>
          <div class="w-1/2 py-3 px-4 uppercase font-semibold text-sm text-white">
            {{ valueLabel }}
          </div>
        </div>
        <div class="flex items-center justify-center p-2" v-if="!readOnly">
          <a href="javascript:void(0);"
            @click="addRow"
            v-tooltip="actionText"
            :style="disableAddingRows ? 'cursor: not-allowed;' : ''"
          ><PlusIcon class="text-gray-400 h-5 hover:text-gray-500"
          /></a>
        </div>
      </div>
      <KeyValueRow
        v-for="({value, key}, index) in rows"
        :ref="`keyValueRow${index}`"
        :loop-key="key"
        :loop-value="value"
        :index="index"
        :key="index"
        :read-only="readOnly"
        :delete-text="deleteText"
        :disable-editing-keys="disableEditingKeys"
        :disable-deleting-rows="disableDeletingRows"
        :key-label="keyLabel"
        :value-label="valueLabel"
        @delete-row="deleteRow"
        @value-updated="valueUpdated"
        @key-updated="keyUpdated"
        @keyup-enter.stop.prevent="onEnterPress(index)"
      />
    </div>
  </div>
  <div v-else>
    -
  </div>
</template>

<script>
import KeyValueRow from '@/js/components/KeyValueRow.vue'
// eslint-disable-next-line import/no-unresolved
import PlusIcon from '@/svgs/plus.svg?inline'

export default {
  props: {
    value: {},
    keyLabel: String,
    valueLabel: String,
    readOnly: Boolean,
    actionText: String,
    deleteText: String,
    disableEditingKeys: Boolean,
    disableAddingRows: Boolean,
    disableDeletingRows: Boolean,
  },
  data: () => ({
    rows: [],
  }),
  components: { KeyValueRow, PlusIcon },
  methods: {
    keyUpdated({ index, value }) {
      this.$set(this.rows[index], 'key', value)
    },
    valueUpdated({ index, value }) {
      this.$set(this.rows[index], 'value', value)
    },
    onEnterPress(index) {
      if (this.rows.length - 1 === index) {
        this.addRow()
      } else {
        this.goToNextRow(index)
      }
    },
    addRow() {
      const length = this.rows.push({ key: '', value: '' })

      setTimeout(() => this.focusRow(length - 1), 1)
    },
    goToNextRow(index) {
      this.focusRow(index + 1)
    },
    focusRow(index) {
      this.$refs[`keyValueRow${index}`][0].$emit('focus')
    },
    deleteRow(index) {
      this.$delete(this.rows, index)
    },
  },
  watch: {
    rows: {
      handler() {
        const parsedValue = {}

        this.rows.forEach((row) => {
          parsedValue[row.key] = row.value
        })

        this.$emit('input', parsedValue)
      },
      deep: true,
    },
  },
  mounted() {
    setTimeout(() => {
      Object.keys(this.value).forEach((key) => {
        const value = this.value[key]

        this.rows.push({ key, value })
      })
    }, 1)
  },
}
</script>
