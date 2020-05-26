<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :value-slot-full-width="true">
    <div v-if="hasFiles" class="relative p-2 bg-gray-200 grid grid-cols-4 gap-2">
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
    <div v-else>
      -
    </div>
    <div v-if="value">
      <img v-if="field.is_image" :src="value" />
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

      // if (this.hasFiles) {
      //   return this.field.value
      // }

      // return []
    },
    getValueFiles() {
      return [...this.files.map((file) => file.id), ...this.addedFiles]
    },
    multiple() {
      return true
    },
  },
  methods: {
    deleteFile(file) {
      console.log('file->', file)
      if (file.id) {
        this.files = this.files.filter((currentFile) => currentFile.id !== file.id)
      } else {
        this.addedFiles = this.addedFiles.filter((currentFile) => currentFile.lastModified !== file.lastModified && currentFile.size !== file.size)
      }

      // const { data } = await Api.delete(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}/fields/${this.field.id}/${file.id}`)
      // console.log('data->', data)
    },
    fileChanged(event) {
      console.log('fileChanged', event, event.target.files)
      // eslint-disable-next-line prefer-destructuring
      this.value = event.target.files
      // event.target.files.forEach((file) => this.files.push(file))


      const { files } = event.target
      // this.addedFiles = event.target.files
      // console.log(event.target.files[0].file)
      for (let i = 0; i < files.length; i++) {
        console.log(files.item(i))
        // get item
        this.addFile(files.item(i))
        // this.files.push(files.item(i))
      }
    },
    addFile(file) {
      this.addedFiles.push(file)
    },
    getValue() {
      // const t = this.getValueFiles.map((file) => {
      //   console.log('file->', file)
      //   if (file.id) return file.id

      //   return file
      // })
      const t = this.getValueFiles
      console.log('t->', t)
      return t
    },
  },
  mounted() {
    this.files = this.field.files
  },
}
</script>
