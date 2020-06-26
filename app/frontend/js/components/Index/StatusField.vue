<template>
  <index-field-wrapper :field="field">
    <div class="spinner" v-if="loading"></div>
    <div :class="classes">
      {{ value }}
    </div>
  </index-field-wrapper>
</template>

<style>
.spinner {
  display: inline-block;

  width: 18px;
  height: 18px;
  margin: 0px 5px -3px 0px;
  background-color: #333;

  border-radius: 100%;
  -webkit-animation: sk-scaleout 1.0s infinite ease-in-out;
  animation: sk-scaleout 1.0s infinite ease-in-out;
}

@-webkit-keyframes sk-scaleout {
  0% { -webkit-transform: scale(0) }
  100% {
    -webkit-transform: scale(1.0);
    opacity: 0;
  }
}

@keyframes sk-scaleout {
  0% {
    -webkit-transform: scale(0);
    transform: scale(0);
  } 100% {
    -webkit-transform: scale(1.0);
    transform: scale(1.0);
    opacity: 0;
  }
}
</style>

<script>
export default {
  props: ['field'],
  computed: {
    classes() {
      const classes = ['inline-block']
      let fail = false
      this.field.failed_when.forEach((item) => {
        if (this.field.value === item) fail = true
      })
      if (fail === true) classes.push(['text-red-700'])

      return classes
    },
    loading() {
      let load = false
      this.field.loading_when.forEach((item) => {
        if (this.field.value === item) load = true
      })
      if (load === true) return true

      return false
    },
    value() {
      return this.field.value
    },
  },
}
</script>
