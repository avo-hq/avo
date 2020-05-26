<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
    <div v-if="hasFiles" class="relative p-2 bg-gray-200 grid grid-cols-4 gap-2 mb-2">
      <div v-for="file in allFiles" :key="file.path" class="relative pb-full">
        <div class="absolute flex z-10 w-full h-full justify-center items-end p-2">
          <a href="javascript:void(0);"
            class="block bg-gray-300 px-2 py-1 rounded inset-auto bottom-0 left-"
            v-tooltip="`Delete ${file.filename}`"
            @click="deleteFile(file)"
          >Delete</a>
        </div>
        <img
          v-tooltip="`${file.filename}`"
          :src="file.path"
          class="absolute h-full w-full object-cover object-center"
          />
      </div>
    </div>
    <div v-if="value">
      <img v-if="field.is_image" :src="value" />
    </div>
    <input type="file"
      :id="field.id"
      :class="classes"
      :disabled="disabled"
      @change="fileChanged"
      multiple
    />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({
    value: [],
    files: [],
    addedFiles: [],
  }),
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
    hasFiles() {
      return this.field.value && this.field.value.length > 0
    },
    allFiles() {
      const addedFiles = this.addedFiles.map((file) => ({
        id: null,
        path: window.URL.createObjectURL(file),
        filename: file.name,
        lastModified: file.lastModified,
        size: file.size,
      }))

      return [...this.files, ...addedFiles]
    },
    getValueFiles() {
      return [...this.files.map((file) => file.id), ...this.addedFiles]
    },
  },
  methods: {
    deleteFile(file) {
      if (file.id) {
        this.files = this.files.filter((currentFile) => currentFile.id !== file.id)
      } else {
        this.addedFiles = this.addedFiles.filter((currentFile) => currentFile.lastModified !== file.lastModified && currentFile.size !== file.size)
      }
    },
    fileChanged(event) {
      // eslint-disable-next-line prefer-destructuring
      this.value = event.target.files

      const { files } = event.target
      for (let i = 0; i < files.length; i++) {
        this.addFile(files.item(i))
      }
    },
    addFile(file) {
      this.addedFiles.push(file)
    },
    getValue() {
      return this.getValueFiles
    },
  },
  mounted() {
    this.files = this.field.files
  },
}
</script>
