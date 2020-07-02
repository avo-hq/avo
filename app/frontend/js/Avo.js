import Api from '@/js/Api'
import Bus from '@/js/Bus'
import PortalVue from 'portal-vue'
import Toasted from 'vue-toasted'
import VModal from 'vue-js-modal'
import VTooltip from 'v-tooltip'
import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import router from '@/js/router'

import '@/js/components'

const Avo = {
  Bus,
  Api,
  env: '',

  init() {
    Avo.env = window.env || 'production'
    if (document.getElementById('app')) {
      Avo.initVue()
    }
  },

  turbolinksLoad() {
    if (document.getElementById('app')) {
      Avo.initVue()
    }
  },

  reload() {
    this.vue.reload()
  },

  initVue() {
    Vue.use(Toasted, {
      duration: 5000,
      keepOnHover: true,
      position: 'bottom-right',
      closeOnSwipe: true,
    })

    Vue.use(VTooltip)
    Vue.use(VueRouter)
    Vue.use(VModal, {
      dynamic: true,
      injectModalsContainer: false,
      dynamicDefaults: {
        height: 200,
        width: 450,
        styles: 'border-radius: 0.5rem',
      },
    })
    Vue.use(PortalVue)

    this.vue = new Vue({
      router,
      el: '#app',
      data: {},
      computed: {
        routerKey() {
          return `${this.$route.name}-${this.$route.params.resourceName || ''}`
        },
      },
      methods: {
        reload() {
          this.$router.go()
        },
        redirect(url) {
          if (this.$route.path === url) return this.reload()

          return this.$router.push(url)
        },
        alert(message, type = 'success') {
          setTimeout(() => {
            this.$toasted.show(message, { type })
          }, 1)
        },
      },
      mounted() {
        Bus.$on('reload', this.reload)
        Bus.$on('redirect', this.redirect)
        Bus.$on('message', (message) => this.alert(message, 'success'))
        Bus.$on('error', (error) => this.alert(error, 'error'))
      },
      destroyed() {
        Bus.$off('reload')
        Bus.$off('redirect')
        Bus.$off('message')
        Bus.$off('error')
      },
    })
  },
}

export { Api }
export default Avo
