/* eslint-disable global-require */
import VueRouter from 'vue-router'

const routes = [
  {
    name: 'dashboard',
    path: '/',
    component: require('@/js/views/Dashboard.vue').default,
  },
  {
    name: 'index',
    path: '/resources/:resourceName',
    component: require('@/js/views/ResourceIndex.vue').default,
    props: true,
  },
  {
    name: 'new',
    path: '/resources/:resourceName/new',
    component: require('@/js/views/ResourceNew.vue').default,
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
    component: require('@/js/views/ResourceShow.vue').default,
    props: (route) => ({
      resourceName: route.params.resourceName,
      resourceId: route.params.resourceId,
      viaRelationship: route.query.viaRelationship,
      viaResourceName: route.query.viaResourceName,
      viaResourceId: route.query.viaResourceId,
    }),
  },
  {
    name: 'edit',
    path: '/resources/:resourceName/:resourceId/edit',
    component: require('@/js/views/ResourceEdit.vue').default,
    props: (route) => ({
      resourceName: route.params.resourceName,
      resourceId: route.params.resourceId,
      viaRelationship: route.query.viaRelationship,
      viaResourceName: route.query.viaResourceName,
      viaResourceId: route.query.viaResourceId,
    }),
  },
  {
    name: '403',
    path: '/403',
    component: require('@/js/views/403.vue').default,
  },
]

const router = new VueRouter({
  mode: 'history',
  base: window.rootPath,
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
