<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value">
        ✅
    </div>
    <div v-else>
        ❌
    </div>
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
