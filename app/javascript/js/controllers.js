import { application } from './application'

/**
 * Auto-register Stimulus Controllers
 * 
 * Convention:
 * - File names: snake_case_controller.js
 * - Import names: PascalCase (e.g., ResourceSearchController)
 * - Registration names: kebab-case (e.g., resource-search)
 */

// Helper functions
function toPascalCase(snakeCase) {
  return snakeCase
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join('')
}

function toKebabCase(snakeCase) {
  return snakeCase.replace(/_/g, '-')
}

// Regular controllers (alphabetical order)
const regularControllers = [
  'action',
  'actions_overflow',
  'actions_picker',
  'attachments',
  'boolean_filter',
  'card_filters',
  'copy_to_clipboard',
  'dashboard_card',
  'date_time_filter',
  'filter',
  'form',
  'hidden_input',
  'input_autofocus',
  'item_select_all',
  'item_selector',
  'loading_button',
  'media_library_attach',
  'media_library',
  'menu',
  'modal',
  'multiple_select_filter',
  'nested_form',
  'per_page',
  'preview',
  'record_selector',
  'resource_edit',
  'resource_index',
  'resource_show',
  'search',
  'select_filter',
  'select',
  'self_destroy',
  'sidebar',
  'sign_out',
  'table_row',
  'tabs',
  'text_filter',
  'tippy',
  'toggle',
  'trix_body'
]

// Field controllers (alphabetical order)
const fieldControllers = [
  'belongs_to_field',
  'clear_input',
  'code_field',
  'date_field',
  'easy_mde',
  'key_value',
  'panel_refresh',
  'progress_bar_field',
  'reload_belongs_to_field',
  'tags_field',
  'tiptap_field',
  'trix_field'
]

// Dynamic imports and registration
async function registerControllers() {
  // Register regular controllers
  for (const controllerName of regularControllers) {
    try {
      const module = await import(`./controllers/${controllerName}_controller.js`)
      const ControllerClass = module.default
      const registrationName = controllerName === 'nested_form' ? 'avo-nested-form' : toKebabCase(controllerName)
      application.register(registrationName, ControllerClass)
    } catch (error) {
      console.warn(`Failed to load controller: ${controllerName}_controller.js`, error)
    }
  }

  // Register field controllers
  for (const controllerName of fieldControllers) {
    try {
      const module = await import(`./controllers/fields/${controllerName}_controller.js`)
      const ControllerClass = module.default
      const registrationName = toKebabCase(controllerName)
      application.register(registrationName, ControllerClass)
    } catch (error) {
      console.warn(`Failed to load field controller: ${controllerName}_controller.js`, error)
    }
  }
}

// Initialize controllers
registerControllers()

// Custom controllers
// To add a new controller:
// 1. Create the file: ./controllers/my_new_controller.js or ./controllers/fields/my_field_controller.js
// 2. Add 'my_new' to regularControllers array or 'my_field' to fieldControllers array
// 3. The controller will be auto-registered as 'my-new' or 'my-field'
