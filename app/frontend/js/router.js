import VueRouter from 'vue-router'

import Dashboard from '@/js/views/Dashboard.vue'
import ResourceEdit from '@/js/views/ResourceEdit.vue'
import ResourceIndex from '@/js/views/ResourceIndex.vue'
import ResourceNew from '@/js/views/ResourceNew.vue'
import ResourceShow from '@/js/views/ResourceShow.vue'

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

export default new VueRouter({
  mode: 'history',
  base: '/avocado',
  routes,
})
