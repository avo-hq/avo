<template>
  <show-field-wrapper :field="field" :index="index">
    <boolean-check
      v-if="field.value != null"
      :checked="field.value" />
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import BooleanCheck from '@/js/components/BooleanCheck.vue'

export default {
  props: ['field', 'index'],
  components: { BooleanCheck },
}
</script>
