<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-text="field.value"></div>
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
