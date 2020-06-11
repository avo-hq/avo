<template>
  <show-field-wrapper :field="field" :index="index">
    <div class="shadow overflow-hidden rounded" v-if="value">
      <table class="min-w-full bg-white">
        <thead class="bg-gray-800 text-white">
          <tr>
            <th class="w-1/2 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ field.key_label }}
            </th>
            <th class="w-1/2 text-left py-3 px-4 uppercase font-semibold text-sm">
              {{ field.value_label }}
            </th>
          </tr>
        </thead>
        <tbody class="text-gray-700">
          <tr v-for="(val, key, index) in value" v-bind:key="index">
            <td class="w-1/2 text-left py-3 px-4">{{ key }}</td>
            <td class="w-1/2 text-left py-3 px-4">{{ val }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <template v-else>
    -
    </template>
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  props: ['field', 'index'],
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = JSON.parse(this.field.value)
      }
    },
  },
}
</script>
