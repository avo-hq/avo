<template>
  <index-field-wrapper :field="field">
    <boolean-check
      v-if="field.value != null"
      :checked="field.value" />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import BooleanCheck from '@/js/components/BooleanCheck.vue'

export default {
  props: ['field'],
  components: { BooleanCheck },
}
</script>
