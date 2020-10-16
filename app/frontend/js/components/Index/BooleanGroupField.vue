<template>
  <index-field-wrapper :field="field" class="text-center">
    <template v-if="value">
        <v-popover>
          <a href="javascript:void(0);" class="tooltip-target">View</a>
          <template slot="popover">
            <div class="space-y-2">
              <template v-for="(val, key, index) in value">
                <div v-bind:key="index">
                  <boolean-check :checked="val"/>
                  <div class="ml-6 text-left py-px">{{ label(key) }}</div>
                </div>
              </template>
            </div>
          </template>
        </v-popover>
    </template>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<style>
  .tooltip-inner, .popover-inner {
    padding: 1rem !important;
    background-color: #ffffff !important;
  }
</style>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import BooleanCheck from '@/js/components/BooleanCheck.vue'

export default {
  mixins: [IsFormField],
  props: ['field'],
  components: { BooleanCheck },
  data: () => ({
    isVisible: false,
  }),
  methods: {
    setInitialValue() {
      if (this.field.value) {
        const values = this.field.value
        const result = {}
        Object.keys(values).forEach((key) => {
          const value = values[key]
          if (value === true || value === false) {
            result[key] = value
          }
        })
        this.value = result
      }
    },
    label(key) {
      if (this.field.options[key]) return this.field.options[key]

      return key
    },
  },
}
</script>
