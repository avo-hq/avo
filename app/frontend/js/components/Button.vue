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
    <span class="text-center w-full" v-if="fullWidth">
      <slot />
    </span>
    <slot v-else />
  </button>
</template>

<script>
export default {
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
    fullWidth() {
      if (!this.$vnode || !this.$vnode.data || !this.$vnode.data.staticClass) return false

      return this.$vnode.data.staticClass.includes('w-full')
    },
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
        } else {
          classes += ' bg-white hover:bg-gray-100'
        }
      }

      if (this.active) {
        classes = classes.replace(`bg-${this.color}-500`, `bg-${this.color}-700`)
      }

      if (this.disabled) {
        classes = classes.replace('cursor-pointer', 'cursor-not-allowed')
      }

      if (this.fullWidth) {
        classes += ' w-full'
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

      // Temporary fix for the button colors to keep them in the bundle in the production build.
      // Colors: red, gray, blue, green, indigo
      // hover:border-red-800 border-red-600 text-red-600 hover:text-red-800 bg-red-300 bg-red-500 hover:bg-red-600 bg-red-700
      // hover:border-gray-800 border-gray-600 text-gray-600 hover:text-gray-800 bg-gray-300 bg-gray-500 hover:bg-gray-600 bg-gray-700
      // hover:border-blue-800 border-blue-600 text-blue-600 hover:text-blue-800 bg-blue-300 bg-blue-500 hover:bg-blue-600 bg-blue-700
      // hover:border-green-800 border-green-600 text-green-600 hover:text-green-800 bg-green-300 bg-green-500 hover:bg-green-600 bg-green-700
      // hover:border-indigo-800 border-indigo-600 text-indigo-600 hover:text-indigo-800 bg-indigo-300 bg-indigo-500 hover:bg-indigo-600 bg-indigo-700
      // hover:border-orange-800 border-orange-600 text-orange-600 hover:text-orange-800 bg-orange-300 bg-orange-500 hover:bg-orange-600 bg-orange-700

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
