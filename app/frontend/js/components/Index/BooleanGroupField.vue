<template>
  <index-field-wrapper :field="field" class="text-center">
    <template v-if="value">
        <v-popover>
          <a class="tooltip-target">View</a>
          <template slot="popover">
            <div class="space-y-3">
              <template v-for="(val, key, index) in value">
                <div v-bind:key="index">
                  <component :is="component(val)" :class="classes(val)" />
                  <div class="text-lg ml-8 text-left">{{ label(key) }}</div>
                </div>
              </template>
            </div>
          </template>
        </v-popover>
    </template>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  props: ['field'],
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
    classes(value) {
      let classes = 'h-6 float-left'

      if (value) {
        classes += ' text-green-600'
      } else {
        classes += ' text-red-600'
      }

      return classes
    },
    component(value) {
      if (value) return 'check-circle-icon'

      return 'x-circle-icon'
    },
  },
}
</script>
