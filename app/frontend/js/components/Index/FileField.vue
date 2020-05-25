<template>
  <index-field-wrapper :field="field">
    <a :href="field.value" v-text="field.filename" v-tooltip="`Download ${field.filename}`" download></a>
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
