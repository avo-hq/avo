
<template>
  <div class="shadow overflow-hidden rounded" v-if="value">
    <table class="min-w-full bg-white">
      <thead class="bg-gray-800 text-white">
        <tr>
          <th class="w-4/9 text-left py-3 px-4 uppercase font-semibold text-sm">
            {{ keyLabel }}
          </th>
          <th class="w-4/9 text-left py-3 px-4 uppercase font-semibold text-sm">
            {{ valueLabel }}
          </th>
          <th class="w-1/9 text-left py-3 px-4 float-right">
            <a href="javascript:void(0);"
              @click="addRow"
              v-tooltip="actionText"
              :style="disableAddingRows ? 'cursor: not-allowed;' : ''"
            ><PlusIcon class="text-gray-400 h-6 hover:text-gray-500"
            /></a>
          </th>
        </tr>
      </thead>
      <tbody class="text-gray-700">
        <KeyValueRow
          v-for="({value, key}, index) in rows"
          :loop-key="key"
          :loop-value="value"
          :index="index"
          :key="index"
          :read-only="readOnly"
          :delete-text="deleteText"
          :disable-editing-keys="disableEditingKeys"
          :disable-deleting-rows="disableDeletingRows"
          @value-updated="valueUpdated"
          @key-updated="keyUpdated"
        >
          <!-- <template #key>
            <input-component
              v-model="loopKey"
            />
          </template>
          <template #value>
            <input-component
              v-model="loopValue"
            />
          </template> -->
        </KeyValueRow>
      </tbody>
    </table>

    <pre>
      {{value}}
    </pre>
  </div>
  <div v-else>
    -
  </div>
</template>

<script>
/* eslint-disable import/no-unresolved */
import KeyValueRow from '@/js/components/KeyValueRow'
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
      console.log('valueUpdated', key)
      // this.$set(this.value, index, { key: this.key, value })
      // this.$set(this.value, index, value)
      // this.$set(this.value, key, value)
      // this.$emit('input', this.value)
    },
    valueUpdated({ index, value }) {
      console.log('valueUpdated', index, value)
      // this.$set(this.value, index, { key: this.key, value })
      // this.$emit('input', this.value)
    },
    addRow() {
      console.log('addRow')
    },
  },
  mounted() {
    // console.log(this.value)
    setTimeout(() => {
      console.log(this.value)
      Object.keys(this.value).forEach((key) => {
        const value = this.value[key]

        this.rows.push({ key, value })
      })
    }, 1)
  },
}
</script>
