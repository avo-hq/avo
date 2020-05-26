<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value">
      <img v-if="field.is_image"
        :src="field.value"
        class="mb-2"
        />
      <a :href="field.value"
        v-tooltip="`Download ${field.filename}`"
        class="inline-block button bg-indigo-600 text-white hover:bg-indigo-800"
        download
      >Download</a>
    </div>
    <div v-else>-</div>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
