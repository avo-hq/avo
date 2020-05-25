<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="value">
      <img v-if="field.is_image" :src="value" />
      <a href="javascript:void(0);"
        v-tooltip="`Delete ${field.filename}`"
        class="my-2 inline-block"
        @click="deleteFile"
      >Delete <span class="font-semibold">{{field.filename}}</span></a>
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
// import isNull from 'lodash/isNull'
// import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [FormField],
  data: () => ({}),
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
      this.value = null
    },
    fileChanged(event) {
      console.log('fileChanged', event, event.target.files)
      // eslint-disable-next-line prefer-destructuring
      this.value = event.target.files[0]
    },
  },
}
</script>
