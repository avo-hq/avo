import Paginate from 'vuejs-paginate'
import Vue from 'vue/dist/vue.esm'
import kebabCase from 'lodash/kebabCase'

Vue.component('paginate', Paginate)

// Fields
Vue.component('index-field-wrapper',                 require('@/js/components/Index/FieldWrapper.vue').default)
Vue.component('index-id-field',                      require('@/js/components/Index/IdField.vue').default)
Vue.component('index-text-field',                    require('@/js/components/Index/TextField.vue').default)
Vue.component('index-textarea-field',                require('@/js/components/Index/TextareaField.vue').default)
Vue.component('index-number-field',                  require('@/js/components/Index/NumberField.vue').default)
Vue.component('index-boolean-field',                 require('@/js/components/Index/BooleanField.vue').default)
Vue.component('index-select-field',                  require('@/js/components/Index/SelectField.vue').default)
Vue.component('index-datetime-field',                require('@/js/components/Index/DatetimeField.vue').default)
Vue.component('index-file-field',                    require('@/js/components/Index/FileField.vue').default)
Vue.component('index-files-field',                   require('@/js/components/Index/FilesField.vue').default)
Vue.component('index-boolean-group-field',           require('@/js/components/Index/BooleanGroupField.vue').default)
Vue.component('index-belongs-to-field',              require('@/js/components/Index/BelongsTo.vue').default)
Vue.component('index-has-one-field',                 require('@/js/components/Index/HasOne.vue').default)
Vue.component('index-status-field',                  require('@/js/components/Index/StatusField.vue').default)
Vue.component('index-currency-field',                require('@/js/components/Index/CurrencyField.vue').default)
Vue.component('index-gravatar-field',                require('@/js/components/Index/GravatarField.vue').default)
Vue.component('index-country-field',                 require('@/js/components/Index/CountryField.vue').default)
Vue.component('index-badge-field',                   require('@/js/components/Index/BadgeField.vue').default)

Vue.component('show-field-wrapper',                  require('@/js/components/Show/FieldWrapper.vue').default)
Vue.component('show-id-field',                       require('@/js/components/Show/IdField.vue').default)
Vue.component('show-text-field',                     require('@/js/components/Show/TextField.vue').default)
Vue.component('show-textarea-field',                 require('@/js/components/Show/TextareaField.vue').default)
Vue.component('show-password-field',                 require('@/js/components/Show/PasswordField.vue').default)
Vue.component('show-number-field',                   require('@/js/components/Show/NumberField.vue').default)
Vue.component('show-boolean-field',                  require('@/js/components/Show/BooleanField.vue').default)
Vue.component('show-select-field',                   require('@/js/components/Show/SelectField.vue').default)
Vue.component('show-datetime-field',                 require('@/js/components/Show/DatetimeField.vue').default)
Vue.component('show-file-field',                     require('@/js/components/Show/FileField.vue').default)
Vue.component('show-files-field',                    require('@/js/components/Show/FilesField.vue').default)
Vue.component('show-key-value-field',                require('@/js/components/Show/KeyValueField.vue').default)
Vue.component('show-boolean-group-field',            require('@/js/components/Show/BooleanGroupField.vue').default)
Vue.component('show-belongs-to-field',               require('@/js/components/Show/BelongsTo.vue').default)
Vue.component('show-has-one-field',                  require('@/js/components/Show/HasOne.vue').default)
Vue.component('show-has-many-field',                 require('@/js/components/Show/HasMany.vue').default)
Vue.component('show-status-field',                   require('@/js/components/Show/StatusField.vue').default)
Vue.component('show-currency-field',                 require('@/js/components/Show/CurrencyField.vue').default)
Vue.component('show-gravatar-field',                 require('@/js/components/Show/GravatarField.vue').default)
Vue.component('show-country-field',                  require('@/js/components/Show/CountryField.vue').default)
Vue.component('show-badge-field',                    require('@/js/components/Show/BadgeField.vue').default)
Vue.component('show-heading-field',                  require('@/js/components/Show/HeadingField.vue').default)
Vue.component('show-code-field',                     require('@/js/components/Show/CodeField.vue').default)
Vue.component('show-trix-field',                     require('@/js/components/Show/TrixField.vue').default)

Vue.component('edit-field-wrapper',                  require('@/js/components/Edit/FieldWrapper.vue').default)
Vue.component('edit-id-field',                       require('@/js/components/Edit/IdField.vue').default)
Vue.component('edit-text-field',                     require('@/js/components/Edit/TextField.vue').default)
Vue.component('edit-textarea-field',                 require('@/js/components/Edit/TextareaField.vue').default)
Vue.component('edit-password-field',                 require('@/js/components/Edit/PasswordField.vue').default)
Vue.component('edit-number-field',                   require('@/js/components/Edit/NumberField.vue').default)
Vue.component('edit-boolean-field',                  require('@/js/components/Edit/BooleanField.vue').default)
Vue.component('edit-select-field',                   require('@/js/components/Edit/SelectField.vue').default)
Vue.component('edit-datetime-field',                 require('@/js/components/Edit/DatetimeField.vue').default)
Vue.component('edit-file-field',                     require('@/js/components/Edit/FileField.vue').default)
Vue.component('edit-files-field',                    require('@/js/components/Edit/FilesField.vue').default)
Vue.component('edit-key-value-field',                require('@/js/components/Edit/KeyValueField.vue').default)
Vue.component('edit-boolean-group-field',            require('@/js/components/Edit/BooleanGroupField.vue').default)
Vue.component('edit-belongs-to-field',               require('@/js/components/Edit/BelongsTo.vue').default)
Vue.component('edit-has-one-field',                  require('@/js/components/Edit/HasOne.vue').default)
Vue.component('edit-status-field',                   require('@/js/components/Edit/StatusField.vue').default)
Vue.component('edit-currency-field',                 require('@/js/components/Edit/CurrencyField.vue').default)
Vue.component('edit-country-field',                  require('@/js/components/Edit/CountryField.vue').default)
Vue.component('edit-heading-field',                  require('@/js/components/Show/HeadingField.vue').default)
Vue.component('edit-code-field',                     require('@/js/components/Edit/CodeField.vue').default)
Vue.component('edit-hidden-field',                   require('@/js/components/Edit/HiddenField.vue').default)
Vue.component('edit-trix-field',                     require('@/js/components/Edit/TrixField.vue').default)

// Form Fields
Vue.component('input-component',                     require('@/js/components/InputComponent.vue').default)

/* View Components */
// Table
Vue.component('resource-table',                      require('@/js/components/Index/TableView/ResourceTable.vue').default)
Vue.component('table-row',                           require('@/js/components/Index/TableView/TableRow.vue').default)
Vue.component('table-header-cell',                   require('@/js/components/Index/TableView/TableHeaderCell.vue').default)

// Grid
Vue.component('resource-grid',                       require('@/js/components/Index/GridView/ResourceGrid.vue').default)
Vue.component('grid-item',                           require('@/js/components/Index/GridView/GridItem.vue').default)

// Common
Vue.component('item-controls',                       require('@/js/components/Index/ItemControls.vue').default)

// Components
Vue.component('view-header',                         require('@/js/components/ViewHeader.vue').default)
Vue.component('view-footer',                         require('@/js/components/ViewFooter.vue').default)
Vue.component('panel',                               require('@/js/components/Panel.vue').default)
Vue.component('pane',                                require('@/js/components/Pane.vue').default)
Vue.component('resource-overview',                   require('@/js/components/ResourceOverview.vue').default)
Vue.component('heading',                             require('@/js/components/Heading.vue').default)
Vue.component('a-button',                            require('@/js/components/Button.vue').default)
Vue.component('resources-search',                    require('@/js/components/ResourcesSearch.vue').default)
Vue.component('loading-component',                   require('@/js/components/LoadingComponent.vue').default)
Vue.component('loading-overlay',                     require('@/js/components/LoadingOverlay.vue').default)
Vue.component('empty-dash',                          require('@/js/components/EmptyDash.vue').default)
Vue.component('empty-state',                         require('@/js/components/EmptyState.vue').default)

// Filters
Vue.component('resource-filters',                    require('@/js/components/Index/ResourceFilters.vue').default)
Vue.component('resource-actions',                    require('@/js/components/ResourceActions.vue').default)
Vue.component('boolean-filter',                      require('@/js/components/Index/Filters/BooleanFilter.vue').default)
Vue.component('select-filter',                       require('@/js/components/Index/Filters/SelectFilter.vue').default)
Vue.component('filter-wrapper',                      require('@/js/components/Index/Filters/FilterWrapper.vue').default)

// Sidebar
Vue.component('resources-navigation',                require('@/js/components/ResourcesNavigation.vue').default)
Vue.component('sidebar-link',                        require('@/js/components/SidebarLink.vue').default)
Vue.component('application-sidebar',                 require('@/js/components/ApplicationSidebar.vue').default)
Vue.component('logo-component',                      require('@/js/components/LogoComponent.vue').default)
Vue.component('license-warnings',                    require('@/js/components/LicenseWarnings.vue').default)
Vue.component('license-warning',                     require('@/js/components/LicenseWarning.vue').default)

// Views
Vue.component('resources-index',                     require('@/js/views/ResourceIndex.vue').default)

// Layouts
Vue.component('app-layout',                          require('@/js/views/AppLayout.vue').default)

// Icons are self imported as ICON_NAME-icon components
// thumbs-up.svg -> <thumbs-up-icon />
const requireComponent = require.context('@/svgs/', false, /.*\.svg$/im)
requireComponent.keys().forEach((fileName) => {
  // Get kebab-case name of component
  const iconName = kebabCase(
    // Gets the file name regardless of folder depth
    fileName
      .split('/')
      .pop()
      .replace(/\.\w+$/, ''),
  )
  const componentName = `${iconName}-icon`
  /* eslint-disable global-require */
  // eslint-disable-next-line import/no-dynamic-require
  const componentConfig = require(`@/svgs/${iconName}.svg?inline`)
  /* eslint-enable global-require */

  Vue.component(componentName, componentConfig)
})
