<template>
  <div class="w-full shadow-lg rounded-lg overflow-hidden" v-if="value">
    <div class="w-full flex flex-col">
      <div class="flex w-full">
        <div class="flex w-full bg-gray-800 shadow overflow-hidden">
          <div class="w-1/2 py-3 px-3 uppercase font-semibold text-xs text-white border-gray-600 border-r">
            {{ keyLabel }}
          </div>
          <div class="w-1/2 py-3 px-3 uppercase font-semibold text-xs text-white">
            {{ valueLabel }}
          </div>
        <div class="flex items-center justify-center p-2 px-3 border-l border-gray-600" v-if="!readOnly">
          <a href="javascript:void(0);"
            @click="addRow"
            v-tooltip="actionText"
            :class="{'cursor-not-allowed': disableAddingRows}"
            data-button="add-row"
          ><plus-circle-icon class="text-gray-400 h-5 hover:text-gray-500"/></a>
        </div>
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
        @keyup-enter="onEnterPress(index)"
      />
    </div>
  </div>
  <div v-else>
    -
  </div>
</template>

<script>
import KeyValueRow from '@/js/components/KeyValueRow.vue'

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
  components: { KeyValueRow },
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
      if (!this.disableAddingRows) {
        const length = this.rows.push({ key: '', value: '' })

        setTimeout(() => this.focusRow(length - 1), 1)
      }
    },
    goToNextRow(index) {
      this.focusRow(index + 1)
    },
    focusRow(index) {
      this.$refs[`keyValueRow${index}`][0].$emit('focus')
    },
    deleteRow(index) {
      if (!this.disableDeletingRows) {
        this.$delete(this.rows, index)
      }
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
