<template>
  <div class="flex flex-shrink-0">
    <div class="spinner" v-if="isLoading"/>
    <div :class="classes" v-text="label"/>
  </div>
</template>

<script>
export default {
  props: {
    status: String,
    label: String,
  },
  computed: {
    classes() {
      const classes = ['inline-block']

      if (this.status === 'fail') classes.push('text-red-700')

      return classes
    },
    isLoading() {
      return this.status === 'load'
    },
  },
}
</script>

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
