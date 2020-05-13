<template>
  <td>
    <a href="javascript:void(0)" @click="open = true" v-if="!open">more</a>
    <div v-if="open">
      {{value}}
    </div>
  </td>
</template>

<script>
export default {
  data: () => ({
    open: false,
  }),
  props: ['value'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>
