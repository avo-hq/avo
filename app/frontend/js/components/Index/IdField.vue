<template>
  <index-field-wrapper :field="field" class="w-12">
    {{field.value}}
  </index-field-wrapper>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>
