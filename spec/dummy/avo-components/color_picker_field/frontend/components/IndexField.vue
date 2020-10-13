<template>
  <index-field-wrapper :field="field">
    <div v-if="field.value"
      class="h-6 px-1 rounded-md text-white text-sm flex items-center justify-center leading-none"
      :style="{backgroundColor: field.value}"
      v-text="field.value"
    />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>

<style></style>
