<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="field.value">
      <img v-if="field.is_image" :src="field.value" />
      <a href="javascript:void(0);"
        v-tooltip="`Delete ${field.filename}`"
        class="my-2 inline-block"
        @click="deleteFile"
      >Delete</a>
    </div>
      <input type="file"
        :id="field.id"
        :class="classes"
        :disabled="disabled"
        @change="fileChanged"
        :multiple="multiple"
      />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [FormField],
  data: () => ({
    file: '',
    hasChanged: false,
    // file: '',
  }),
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
    multiple() {
      return false
    },
  },
  methods: {
    deleteFile() {
      this.field.value = null
      this.field.filename = null
      this.hasChanged = true
    },
    fileChanged(event) {
      this.hasChanged = true
      console.log('fileChanged', event, event.target.files)
      // eslint-disable-next-line prefer-destructuring
      this.file = event.target.files[0]
    },
    getFileFieldValue() {
      /* eslint-disable camelcase */
      return {
        has_changed: this.hasChanged,
        file: this.file,
      }
      /* eslint-enable camelcase */
    },
  },
  mounted() {
    // this.field.updatable = !isNull(this.field.value) && !isUndefined(this.field.value)
  },
}
</script>
