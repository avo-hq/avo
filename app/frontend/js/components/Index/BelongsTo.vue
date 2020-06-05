<template>
  <index-field-wrapper :field="field">
    <div v-if="field.value" v-text="field.value"></div>
    <div v-else>-</div>
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
}
</script>
