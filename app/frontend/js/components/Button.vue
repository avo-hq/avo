<template>
  <button class="inline-flex flex-grow-0 items-center text-sm font-bold leading-none fill-current whitespace-no-wrap transition duration-100 rounded-lg shadow-xl"
    ref="button"
    :is="element"
    :class="classes"
    :to="to"
    :exact="exact"
    :disabled="disabled"
    :href="realHref"
    @click="$emit('click')"
  >
    <slot />
  </button>
</template>

<script>
export default {
  data: () => ({}),
  props: [
    'to',
    'exact',
    'onClick',
    'color',
    'variant',
    'disabled',
    'href',
    'size',
    'active',
  ],
  computed: {
    classes() {
      let classes = 'transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer'

      if (this.color) {
        if (this.isOutlined) {
          classes += ' bg-white border'

          if (this.disabled) {
            classes += ' border-gray-300 text-gray-600'
          } else {
            classes += ` hover:border-${this.color}-800 border-${this.color}-600 text-${this.color}-600 hover:text-${this.color}-800`
          }
        } else {
          classes += ' text-white'

          if (this.disabled) {
            classes += ` bg-${this.color}-300`
          } else {
            classes += ` bg-${this.color}-500 hover:bg-${this.color}-600`
          }
        }
      } else {
        classes += ' text-gray-800'

        if (this.disabled) {
          classes += ' bg-gray-300'
          classes = classes.replace('cursor-pointer', 'cursor-not-allowed')
        } else {
          classes += ' bg-white hover:bg-gray-100'
        }
      }

      if (this.active) {
        classes = classes.replace(`bg-${this.color}-500`, `bg-${this.color}-700`)
      }

      switch (this.size) {
        case 'xs':
          classes += ' p-2 py-1'
          break
        case 'sm':
          classes += ' p-3'
          break
        default:
        case 'md':
          classes += ' p-4'
          break
      }

      return classes
    },
    isOutlined() {
      return this.variant === 'outlined'
    },
    element() {
      if (this.to) return 'router-link'
      if (this.href) return 'a'

      return 'button'
    },
    realHref() {
      if (this.href) return this.href
      // eslint-disable-next-line no-script-url
      if (this.to) return 'javascript:void(0);'

      return null
    },
  },
  methods: {
    focus() {
      this.$refs.button.focus()
    },
  },
  mounted() {
    this.$on('focus', this.focus)
  },
  destroyed() {
    this.$off('focus')
  },
}
</script>
