<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="value">
      <img v-if="field.is_image" :src="value" />
      <a href="javascript:void(0);"
        class="my-2 inline-block button bg-indigo-600 text-white hover:bg-indigo-800"
        @click="deleteFile"
      >Delete <span class="font-semibold">{{field.filename}}</span></a>
    </div>
    <input type="file"
      :id="field.id"
      :class="classes"
      :disabled="disabled"
      @change="fileChanged"
    />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    deleteFile() {
      this.value = null
    },
    fileChanged(event) {
      // eslint-disable-next-line prefer-destructuring
      this.value = event.target.files[0]
    },
    getId() {
      // Temporary solution to allow creation of a form with file fields without files attached
      if (this.value) return this.field.id

      return null
    },
  },
}
</script>
