
<template>
  <div class="shadow overflow-hidden rounded" v-if="value">
      <table class="min-w-full bg-white">
        <thead class="bg-gray-800 text-white">

          <tr v-if="readOnly">
            <th class="w-1/2 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ keyLabel }}
            </th>
            <th class="w-1/2 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ valueLabel }}
            </th>
          </tr>

          <tr v-else>
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
            v-for="(val, key, index) in value"
            :value="val"
            :map-key="key"
            :key="key"
            :read-only="readOnly"
            :delete-text="deleteText"
            :disable-editing-keys="disableEditingKeys"
            :disable-deleting-rows="disableDeletingRows"
            @value-updated="valueUpdated()"
          >
          </KeyValueRow>
        </tbody>
      </table>
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
    value: {

    },
    keyLabel: String,
    valueLabel: String,
    readOnly: Boolean,
    actionText: String,
    deleteText: String,
    disableEditingKeys: Boolean,
    disableAddingRows: Boolean,
    disableDeletingRows: Boolean,
  },
  components: { KeyValueRow, PlusIcon },
  methods: {
    valueUpdated(index, value) {
      this.$set(this.value, key, value)
      this.$emit('input', this.value)
    }
  },
}
</script>
