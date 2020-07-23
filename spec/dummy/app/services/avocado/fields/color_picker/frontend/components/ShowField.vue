<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value"
      class="h-6 px-1 rounded-md text-white text-sm flex items-center justify-center leading-none"
      :style="{backgroundColor: field.value}"
      v-text="field.value"
    />
    <empty-dash v-else />
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

<style></style>
