import '@/js/components'
import Api from '@/js/Api'
import Bus from '@/js/Bus'
import PortalVue from 'portal-vue'
import Toasted from 'vue-toasted'
import VModal from 'vue-js-modal'
import VTooltip from 'v-tooltip'
import Vue from 'vue/dist/vue.esm'
import VueCurrencyInput from 'vue-currency-input'
import VueRouter from 'vue-router'
import Vuex from 'vuex'
import indexStore from '@/js/stores/index-store'
import router from '@/js/router'

const Avo = {
  Bus,
  Api,
  env: '',
  rootPath: window.rootPath || '/avo',

  init() {
    Avo.env = window.env || 'production'
    if (document.getElementById('app')) {
      Avo.initVue()
    }
  },

  reload() {
    this.vue.reload()
  },

  redirect(path) {
    this.vue.redirect(path)
  },

  alert(message, messageType) {
    this.vue.alert(message, messageType)
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
    Vue.use(VueCurrencyInput)
    Vue.use(VModal, {
      dynamic: true,
      injectModalsContainer: false,
      dynamicDefaults: {
        adaptive: true,
        height: 'auto',
        minHeight: 250,
        width: 550,
        styles: 'border-radius: 1rem',
      },
    })
    Vue.use(PortalVue)
    Vue.use(Vuex)

    const store = new Vuex.Store({
      modules: {
        index: indexStore,
      },
    })

    this.vue = new Vue({
      router,
      store,
      el: '#app',
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

export { Api, Bus }
export default Avo
