<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <select class="select-input w-full" :class="classes" v-model="value">
      <option v-for="(option, key) in field.options" :value="key" :key="key">
        {{option}}
      </option>
    </select>
  </edit-field-wrapper>
</template>

<script>
/* eslint-disable max-len */
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [FormField, HasInputAppearance],
}
</script>

<style>
select.select-input {
  background-repeat: no-repeat;
  background-position: right .5rem center;
  background-image: url(data:image/svg+xml;base64,PHN2ZyBhcmlhLWhpZGRlbj0idHJ1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhZCIgZGF0YS1pY29uPSJjaGV2cm9uLWRvd24iIHJvbGU9ImltZyIgaGVpZ2h0PSIxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgNDQ4IDUxMiIgY2xhc3M9InN2Zy1pbmxpbmUtLWZhIGZhLWNoZXZyb24tZG93biBmYS13LTE0IGZhLTd4Ij48ZyBjbGFzcz0iZmEtZ3JvdXAiPjxwYXRoIGZpbGw9ImN1cnJlbnRDb2xvciIgZD0iTTIyNC4xIDI4NC42NGwtNTYuODkgNTYuNzgtMTU0LTE1NC4zMWEyNCAyNCAwIDAgMSAwLTMzLjk0bDIyLjY1LTIyLjdhMjMuOTMgMjMuOTMgMCAwIDEgMzMuODQgMHoiIGNsYXNzPSJmYS1zZWNvbmRhcnkiPjwvcGF0aD48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik00MzUgMTg3LjE1TDI0MSAzODEuNDhhMjMuOTQgMjMuOTQgMCAwIDEtMzMuODQgMGwtNDAtNDAgMjExLjM0LTIxMWEyMy45MyAyMy45MyAwIDAgMSAzMy44NCAwTDQzNSAxNTMuMjFhMjQgMjQgMCAwIDEgMCAzMy45NHoiIGNsYXNzPSJmYS1wcmltYXJ5Ij48L3BhdGg+PC9nPjwvc3ZnPg==);
}
</style>
