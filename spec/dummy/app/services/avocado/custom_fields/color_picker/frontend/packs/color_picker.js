import EditField from '../components/EditField.vue'
import IndexField from '../components/IndexField.vue'
import ShowField from '../components/ShowField.vue'

// console.log('window.Avo->', window.Avo)

window.Avo.initializing((Vue) => {
  console.log('in initializing', window.Avo, Vue)
  Vue.component('edit-color-picker-field', EditField)
  Vue.component('index-color-picker-field', IndexField)
  Vue.component('show-color-picker-field', ShowField)
})
