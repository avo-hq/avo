<template>
  <index-field-wrapper :field="field">
    <div v-if="field.value" v-text="field.value"></div>
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
