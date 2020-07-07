<template>
  <div :field="field" :errors="errors" :index="index">
    <input type="hidden" :value="value" />
  </div>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
}
</script>
