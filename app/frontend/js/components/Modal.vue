<template>
  <div class="p-8 w-full h-full flex flex-col">
    <div class="flex-1 flex items-center justify-center">
      {{ text }}
    </div>
    <div class="flex justify-center space-x-4">
      <button
        class="button border-red-700 text-red-700"
        v-if="confirmAction"
        @click="confirmAction"
      >
        confirm
      </button>
      <button class="button" v-if="confirmAction" @click="$emit('close')">
        cancel
      </button>
    </div>
  </div>
</template>

<script>

export default {
  data: () => ({}),
  props: ['text', 'confirmAction'],
  computed: {},
  methods: {},
  mounted() { },
}
</script>

<style lang="postcss"></style>
