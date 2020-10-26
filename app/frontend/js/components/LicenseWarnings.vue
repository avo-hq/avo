<template>
  <div>
    <license-warning v-if="license.id === 'pro' && !license.valid"
      title="Trial Mode"
      message="You are experiencing paid features that need to be licensed before deploying this site. Enjoy!"
      icon="exclamation"
    />
    <license-warning v-if="license.error"
      title="Avo HQ Error"
      :message="errorMessage"
      icon="exclamation"
    />
  </div>
</template>

<script>
export default {
  data: () => ({
    license: window.license,
  }),
  computed: {
    errorMessage() {
      return `${this.license.error}. Checking back every 5 minutes.`
    },
  },
}
</script>
