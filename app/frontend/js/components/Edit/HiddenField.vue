<template>
  <div :field="field" :errors="errors" :index="index">
    <input type="hidden" :value="value" />
  </div>
</template>

<script>
import { IsFormField } from '@avocadohq/avocado-js'

export default {
  mixins: [IsFormField],
}
</script>
