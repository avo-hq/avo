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
    props: (route) => ({
      resourceName: route.params.resourceName,
      viaRelationship: route.query.viaRelationship,
      viaResourceName: route.query.viaResourceName,
      viaResourceId: route.query.viaResourceId,
    }),
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
    props: (route) => ({
      resourceName: route.params.resourceName,
      resourceId: route.params.resourceId,
      viaRelationship: route.query.viaRelationship,
      viaResourceName: route.query.viaResourceName,
      viaResourceId: route.query.viaResourceId,
    }),
  },
]

const router = new VueRouter({
  mode: 'history',
  base: '/avocado',
  routes,
})

router.beforeResolve((to, from, next) => {
  // If this isn't an initial page load.
  if (to.name) {
    document.querySelector('body').classList.add('route-loading')
  }

  next()
})

router.afterEach(() => {
  document.querySelector('body').classList.remove('route-loading')
})

export default router
