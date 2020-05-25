<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value">
      <img v-if="field.is_image" :src="field.value" />
      <a :href="field.value"
        v-tooltip="`Download ${field.filename}`"
        class="mt-2 inline-block"
        download
      >Download</a>
    </div>
    <div v-else>-</div>
  </show-field-wrapper>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field', 'index'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
