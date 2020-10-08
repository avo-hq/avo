<template>
  <div :field="field" :errors="errors" :index="index">
    <input type="hidden" :value="value" />
  </div>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'

export default {
  mixins: [IsFormField],
}
</script>
