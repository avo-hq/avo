import EditField from '@/components/EditField.vue'
import IndexField from '@/components/IndexField.vue'
import ShowField from '@/components/ShowField.vue'

import '@/stylesheets/field.scss'

if (window.Avo) {
  window.Avo.initializing((Vue) => {
    Vue.component('edit-<%= class_name.parameterize %>-field', EditField)
    Vue.component('index-<%= class_name.parameterize %>-field', IndexField)
    Vue.component('show-<%= class_name.parameterize %>-field', ShowField)
  })
}
