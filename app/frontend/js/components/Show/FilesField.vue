<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <div v-if="hasFiles" class="relative p-2 bg-gray-200 grid grid-cols-3 lg:grid-cols-4 gap-2">
      <div v-for="file in field.files" :key="file.path" class="relative pb-full">
        <a :href="file.path"
          class="w-full h-full block"
          v-tooltip="`Download ${file.filename}`"
          download
        >
          <img
          :src="file.path"
          class="absolute h-full w-full object-cover object-center"
          />
        </a>
      </div>
    </div>
    <div v-else>
      -
    </div>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    hasFiles() {
      return this.field.value && this.field.value.length > 0
    },
    files() {
      if (this.hasFiles) {
        return this.field.value
      }

      return []
    },
  },
}
</script>
