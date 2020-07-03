<template>
  <index-field-wrapper :field="field">
    <div v-if="field.value" v-text="field.value"/>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
}
</script>
