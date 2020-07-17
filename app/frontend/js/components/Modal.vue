<template>
  <div class="w-full h-full flex flex-col justify-between">
    <div class="p-4 mt-4 text-lg tracking-wide font-bold text-center text-gray-700" v-if="heading">
      {{ heading }}
    </div>
    <div class="flex-1 flex items-center justify-center px-8 text-lg">
      {{ text }}
    </div>
    <div class="flex justify-end items-baseline space-x-4 p-4 bg-gray-200">
      <a-button
        v-if="confirmAction"
        size="sm"
        @click="$emit('close')"
      >
        Cancel
      </a-button>
      <a-button
        ref="confirm-button"
        color="red"
        variant="outlined"
        size="sm"
        v-if="confirmAction"
        @click="confirmAction"
      >
        Confirm
      </a-button>
    </div>
  </div>
</template>

<script>
export default {
  props: ['heading', 'text', 'confirmAction'],
  mounted() {
    this.$refs['confirm-button'].focus()
  },
}
</script>
