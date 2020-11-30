<template>
  <div class="w-10/12 ml-1/12 inset-auto bottom-0 z-50 my-4 opacity-50 hover:opacity-100 transition-opacity duration-150 group">
    <a href="https://avohq.io/pricing" target="_blank" class="rounded bg-teal-700 text-white py-2 px-4 text-sm block group-hover:pt-4">
      <div class="h-6 inline mr-1" :is="iconElement" v-if="icon" /> <strong v-text="title" />
      <div class="group-hover:block hidden py-2">
        {{message}} <arrow-circle-right-icon class="h-6 inline float-right"></arrow-circle-right-icon>
      </div>
    </a>
  </div>
</template>

<script>
export default {
  props: ['title', 'message', 'icon'],
  computed: {
    iconElement() {
      if (this.icon) return `${this.icon}-icon`

      return null
    },
  },
}
</script>
