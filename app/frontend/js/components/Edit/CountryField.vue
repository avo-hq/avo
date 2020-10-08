<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
      :id="field.id"
    >
      <option value="null" v-text="field.placeholder"/>
      <option v-for="(name, code) in field.countries"
        :value="code"
        :key="code"
        v-text="name"
      />
    </select>
  </edit-field-wrapper>
</template>

<script>
import { HasInputAppearance, IsFormField } from '@avo-hq/avo-js'

export default {
  mixins: [IsFormField, HasInputAppearance],
}
</script>
