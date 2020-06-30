<template>
  <div>
    <img :src="gravatarURL" :class="classes"/>
  </div>
</template>

<script>
export default {
  props: {
    hashedEmail: String,
    rounded: Boolean,
    squared: Boolean,
    size: Number,
    defaultUrl: String,
  },
  computed: {
    // hashedEmail() {
    //   return this.email.trim().toLowerCase()
    // },
    gravatarURL() {
      let gravatarURL = 'https://www.gravatar.com/avatar/' + this.hashedEmail

      if (this.defaultUrl !== '') gravatarURL += '?default=' + this.defaultUrl
      if (this.size > 0 && this.size < 2049) gravatarURL += '?size=' + this.size

      console.log(gravatarURL)
      return gravatarURL
    },
    classes() {
      const classes = []

      if (this.rounded) classes.push('rounded-avatar')
      if (this.squared) classes.push('squared-avatar')

      return classes.join(' ')
    },
  },
}
</script>

<style>
  .rounded-avatar {
      border-radius: 50%;
  }

  .squared-avatar {
      border-radius: 0%;
  }
</style>
