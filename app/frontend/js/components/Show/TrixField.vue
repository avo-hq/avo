<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <p v-if="field.value" v-html="field.value"/>
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
