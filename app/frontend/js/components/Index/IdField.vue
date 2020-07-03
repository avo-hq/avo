<template>
  <index-field-wrapper :field="field" class="w-12">
    <div v-if="field.value" v-text="field.value"></div>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
}
</script>
