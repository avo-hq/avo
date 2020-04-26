import * as Mousetrap from 'mousetrap';
import * as Turbolinks from 'turbolinks';
import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm.js'
import Vuex from 'vuex'
import VueRouter from 'vue-router'

import Dashboard from './views/Dashboard'
import ResourceNew from './views/ResourceNew'
import ResourceIndex from './views/ResourceIndex'
import ResourceShow from './views/ResourceShow'
import ResourceEdit from './views/ResourceEdit'

import './components'
import './fields'

Vue.use(VueRouter)
Vue.use(Vuex);
Vue.use(TurbolinksAdapter)


Vue.component('index-id-field', require('./components/Index/IdField').default)
Vue.component('index-text-field', require('./components/Index/TextField').default)

Vue.component('show-id-field', require('./components/Show/IdField').default)
Vue.component('show-text-field', require('./components/Show/TextField').default)

Vue.component('edit-text-field', require('./components/Edit/TextField').default)

Vue.component('resource-table', require('./components/Index/ResourceTable').default)
Vue.component('table-row', require('./components/Index/TableRow').default)

Vue.component('view-header', require('./components/ViewHeader').default)
Vue.component('view-footer', require('./components/ViewFooter').default)
Vue.component('panel', require('./components/Panel').default)
Vue.component('field-wrapper', require('./components/FieldWrapper').default)
Vue.component('heading', require('./components/Heading').default)


const routes = [
  {
    path: '/',
    component: Dashboard,

  },
  {
    name: 'index',
    path: '/resources/:resourceName',
    component: ResourceIndex,
    props: true,
  },
  {
    name: 'new',
    path: '/resources/:resourceName/new',
    component: ResourceNew,
    props: true,
  },
  {
    name: 'show',
    path: '/resources/:resourceName/:resourceId',
    component: ResourceShow,
    props: true,
  },
  {
    name: 'edit',
    path: '/resources/:resourceName/:resourceId/edit',
    component: ResourceEdit,
    props: true,
  },
]
const router = new VueRouter({
  mode: 'history',
  base: '/avocado',
  routes
})


// import {store} from '@/src/store'

Mousetrap.bind('r r r', () => Turbolinks.visit(window.location.href));

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    router,
    el: '#app',
    // store,
    data: () => {
      return {
        message: "Can you say hello?"
      }
    },
    methods: {
      reload() {
        Turbolinks.visit(window.location.href);
      },
    },
    mounted() {
      this.$on('reload', this.reload)
    },
    destroyed() {
      this.$off('reload')
    },
  })
})
