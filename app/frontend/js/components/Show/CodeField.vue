<template>
  <show-field-wrapper :field="field" :index="index" :value-slot-full-width="true">
    <code-component
      :value="field.value"
      :language="field.language"
      :theme="field.theme"
      :editable="false"
    />
  </show-field-wrapper>
</template>

<script>
import CodeComponent from '@/js/components/CodeComponent.vue'

export default {
  props: ['field', 'index'],
  components: { CodeComponent },
}
</script>
