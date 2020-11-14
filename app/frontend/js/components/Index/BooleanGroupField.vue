<template>
  <index-field-wrapper :field="field" class="text-center">
    <v-popover>
      <a href="javascript:void(0);" class="tooltip-target">{{ $t('avo.view') | upperFirst() }}</a>
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
  </index-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import BooleanCheck from '@/js/components/BooleanCheck.vue'
import hasUpperFirstFilter from '@/js/mixins/has-upper-first-filter'

export default {
  mixins: [IsFormField, hasUpperFirstFilter],
  props: ['field'],
  components: { BooleanCheck },
  data: () => ({
    isVisible: false,
  }),
  methods: {
    setInitialValue() {
      const result = {}
      Object.keys(this.field.options).forEach((key) => {
        result[key] = (this.field.value && key in this.field.value && this.field.value[key] === true)
      })
      this.value = result
    },
    label(key) {
      if (this.field.options[key]) return this.field.options[key]

      return key
    },
  },
}
</script>

<style>
  .tooltip-inner, .popover-inner {
    padding: 1rem !important;
    background-color: #ffffff !important;
  }
</style>
