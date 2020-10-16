<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value">
      <img v-if="field.is_image"
        :src="field.value"
        class="mb-2 rounded-lg"
        />
    </div>
    <empty-dash v-else />
    <template #extra>
      <a-button :href="field.value"
        color="indigo"
        v-tooltip="`Download ${field.filename}`"
        v-if="field.value"
        download
      ><download-icon class="h-4 mr-1" /> Download</a-button>
    </template>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
