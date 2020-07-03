<template>
  <show-field-wrapper :field="field" :index="index">
    <router-link :to="field.link"
      v-if="field.link"
      v-text="field.value"></router-link>
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
