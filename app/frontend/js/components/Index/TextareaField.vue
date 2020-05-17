<template>
  <index-field-wrapper :field="field">
    <a href="javascript:void(0)" @click="open = true" v-if="!open">more</a>
    <div v-if="open">
      {{field.value}}
    </div>
  </index-field-wrapper>
</template>

<script>
export default {
  data: () => ({
    open: false,
  }),
  props: ['field'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>
