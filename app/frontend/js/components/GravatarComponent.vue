<template>
  <img :src="gravatarURL"
    :class="{'rounded-full': rounded}"
    class="min-w-10"
  />
</template>

<script>
import URI from 'urijs'

export default {
  props: {
    hashedEmail: String,
    default: {
      type: String,
      default: null,
    },
    rounded: {
      type: Boolean,
      default: false,
    },
    size: {
      type: Number,
      default: 340,
    },
  },
  computed: {
    gravatarURL() {
      const gravatarURL = new URI(`https://www.gravatar.com/avatar/${this.hashedEmail}`)

      return gravatarURL.query({
        default: this.default,
        size: this.size,
      }).toString()
    },
  },
}
</script>
