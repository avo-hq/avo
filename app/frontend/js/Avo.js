import Api from '@/js/Api'
import Bus from '@/js/Bus'
import Paginate from 'vuejs-paginate'
import PortalVue from 'portal-vue'
import Toasted from 'vue-toasted'
import VModal from 'vue-js-modal'
import VTooltip from 'v-tooltip'
import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import router from '@/js/router'
import store from  '@/js/store'

Vue.component('paginate', Paginate)

// Fields
Vue.component('index-field-wrapper',             require('@/js/components/Index/FieldWrapper.vue').default)
Vue.component('index-id-field',                  require('@/js/components/Index/IdField.vue').default)
Vue.component('index-text-field',                require('@/js/components/Index/TextField.vue').default)
Vue.component('index-belongs-to-field',          require('@/js/components/Index/BelongsTo.vue').default)
Vue.component('index-textarea-field',            require('@/js/components/Index/TextareaField.vue').default)
Vue.component('password-field-wrapper',          require('@/js/components/Index/PasswordField.vue').default)

Vue.component('show-field-wrapper',              require('@/js/components/Show/FieldWrapper.vue').default)
Vue.component('show-id-field',                   require('@/js/components/Show/IdField.vue').default)
Vue.component('show-text-field',                 require('@/js/components/Show/TextField.vue').default)
Vue.component('show-belongs-to-field',           require('@/js/components/Show/BelongsTo.vue').default)
Vue.component('show-has-many-field',             require('@/js/components/Show/HasMany.vue').default)
Vue.component('show-textarea-field',             require('@/js/components/Show/TextareaField.vue').default)
Vue.component('show-password-field',             require('@/js/components/Show/PasswordField.vue').default)

Vue.component('edit-text-field',                 require('@/js/components/Edit/TextField.vue').default)
Vue.component('edit-belongs-to-field',           require('@/js/components/Edit/BelongsTo.vue').default)
Vue.component('edit-textarea-field',             require('@/js/components/Edit/TextareaField.vue').default)
Vue.component('edit-password-field',             require('@/js/components/Edit/PasswordField.vue').default)
// Vue.component('edit-field-wrapper',           require('@/js/components/Edit/FieldWrapper.vue').default)

// Components
Vue.component('resource-table',                  require('@/js/components/Index/ResourceTable.vue').default)
Vue.component('table-row',                       require('@/js/components/Index/TableRow.vue').default)
Vue.component('table-header-cell',               require('@/js/components/Index/TableHeaderCell.vue').default)

Vue.component('view-header',                     require('@/js/components/ViewHeader.vue').default)
Vue.component('view-footer',                     require('@/js/components/ViewFooter.vue').default)
Vue.component('panel',                           require('@/js/components/Panel.vue').default)
Vue.component('heading',                         require('@/js/components/Heading.vue').default)
Vue.component('resources-search',                require('@/js/components/ResourcesSearch.vue').default)
Vue.component('resources-filter',                require('@/js/components/ResourcesFilter.vue').default)
Vue.component('select-filter',                   require('@/js/components/Index/Filters/SelectFilter.vue').default)

// Sidebar
Vue.component('resources-navigation',            require('@/js/components/ResourcesNavigation.vue').default)
Vue.component('sidebar-link',                    require('@/js/components/SidebarLink.vue').default)
Vue.component('application-sidebar',             require('@/js/components/ApplicationSidebar.vue').default)
Vue.component('logo-component',                  require('@/js/components/LogoComponent.vue').default)

// Views
Vue.component('resources-index',                 require('@/js/views/ResourceIndex.vue').default)

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
    Vue.use(VModal, { dynamic: true, injectModalsContainer: false })
    Vue.use(PortalVue)

    this.vue = new Vue({
      router,
      store,
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
