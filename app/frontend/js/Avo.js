import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import Turbolinks from 'turbolinks'
import Toasted from 'vue-toasted'
import router from '@/js/router'
import store from '@/js/store'
import Api from '@/js/Api'
import Bus from '@/js/Bus'

Vue.component('index-id-field', require('@/js/components/Index/IdField').default)
Vue.component('index-text-field', require('@/js/components/Index/TextField').default)

Vue.component('show-id-field', require('@/js/components/Show/IdField').default)
Vue.component('show-text-field', require('@/js/components/Show/TextField').default)

Vue.component('edit-text-field', require('@/js/components/Edit/TextField').default)

Vue.component('resource-table', require('@/js/components/Index/ResourceTable').default)
Vue.component('table-row', require('@/js/components/Index/TableRow').default)

Vue.component('view-header', require('@/js/components/ViewHeader').default)
Vue.component('view-footer', require('@/js/components/ViewFooter').default)
Vue.component('panel', require('@/js/components/Panel').default)
Vue.component('field-wrapper', require('@/js/components/FieldWrapper').default)
Vue.component('heading', require('@/js/components/Heading').default)
Vue.component('resources-navigation', require('@/js/components/ResourcesNavigation').default)

const Avo = {
  Bus,
  Api,
  env: '',

  init() {
    Avo.env = window.env || 'production'
  },

  turbolinksLoad() {
    console.log('turbolinksLoad')
    if (document.getElementById('app')) {
      Avo.initVue()
    }
    // App.initMiscModules();
    // App.initPage();
    // App.Common.initWhiteBox();

    // if (App.env === 'production') {
    //   App.trackGS();
    // }
  },

  // constructor() {
  //   this.bus = new Vue()
  // }

  initVue() {
    Vue.use(Toasted, {
      duration: 5000,
      keepOnHover: true,
      position: 'bottom-right',
      closeOnSwipe: true,
    })
    Vue.use(VueRouter)
    Vue.use(TurbolinksAdapter)

    this.vue = new Vue({
      router,
      store,
      el: '#app',
      data: {},
      methods: {
        reload() {
          Turbolinks.visit(window.location.href)
        },
        redirect(url) {
          Turbolinks.visit(url)
        },
        alert(message, type = 'success') {
          this.$toasted.show(message, { type })
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
      },
    })
  },
}

export { Api }
export default Avo
