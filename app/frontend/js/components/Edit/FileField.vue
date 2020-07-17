<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="value">
      <img v-if="field.is_image" :src="value" class="rounded-lg" />
    </div>
    <input type="file"
      :id="field.id"
      :class="classes"
      :disabled="disabled"
      @change="fileChanged"
    />
    <template #extra>
      <a-button color="indigo"
        @click="deleteFile"
      ><trash-icon class="h-4 mr-1" /> Delete {{field.filename}}</a-button>
    </template>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  computed: {
    classes() {
      const classes = ['w-full', 'mt-6']

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
