<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-if="field.value" v-text="field.value"/>
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
