<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-text="field.value"></div>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
}
</script>
