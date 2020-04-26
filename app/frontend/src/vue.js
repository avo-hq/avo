import * as Mousetrap from 'mousetrap';
import * as Turbolinks from 'turbolinks';
import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm.js'
import Vuex from 'vuex'
import VueRouter from 'vue-router'

import Dashboard from './components/Dashboard'
import ResourceIndex from './components/ResourceIndex'
import ResourceDetail from './components/ResourceDetail'

import './components'
import './fields'

Vue.use(VueRouter)
Vue.use(Vuex);
Vue.use(TurbolinksAdapter)


Vue.component('index-text-field', require('./components/Index/TextField').default)

Vue.component('resource-table', require('./components/ResourceTable').default)
Vue.component('table-row', require('./components/Index/TableRow').default)


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
    name: 'detail',
    path: '/resources/:resourceName/:resourceId',
    component: ResourceDetail,
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
