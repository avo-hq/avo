<template>
  <index-field-wrapper :field="field" class="text-center">
    <div v-if="field.value">
        ✅
    </div>
    <div v-else>
        ❌
    </div>
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
