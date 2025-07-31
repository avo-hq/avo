import { application } from './application'

import ActionController from './controllers/action_controller'
import ActionsOverflowController from './controllers/actions_overflow_controller'
import ActionsPickerController from './controllers/actions_picker_controller'
import AttachmentsController from './controllers/attachments_controller'
import BelongsToFieldController from './controllers/fields/belongs_to_field_controller'
import BooleanFilterController from './controllers/boolean_filter_controller'
import CardFiltersController from './controllers/card_filters_controller'
import ClearInputController from './controllers/fields/clear_input_controller'
import CodeFieldController from './controllers/fields/code_field_controller'
import CopyToClipboardController from './controllers/copy_to_clipboard_controller'
import DashboardCardController from './controllers/dashboard_card_controller'
import DateFieldController from './controllers/fields/date_field_controller'
import DateTimeFilterController from './controllers/date_time_filter_controller'
import EasyMdeController from './controllers/fields/easy_mde_controller'
import FilterController from './controllers/filter_controller'
import FormController from './controllers/form_controller'
import HiddenInputController from './controllers/hidden_input_controller'
import InputAutofocusController from './controllers/input_autofocus_controller'
import ItemSelectAllController from './controllers/item_select_all_controller'
import ItemSelectorController from './controllers/item_selector_controller'
import KeyValueController from './controllers/fields/key_value_controller'
import LoadingButtonController from './controllers/loading_button_controller'
import MediaLibraryAttachController from './controllers/media_library_attach_controller'
import MediaLibraryController from './controllers/media_library_controller'
import MenuController from './controllers/menu_controller'
import ModalController from './controllers/modal_controller'
import MultipleSelectFilterController from './controllers/multiple_select_filter_controller'
import NestedFormController from './controllers/nested_form_controller'
import PanelRefreshController from './controllers/fields/panel_refresh_controller'
import PerPageController from './controllers/per_page_controller'
import PreviewController from './controllers/preview_controller'
import ProgressBarFieldController from './controllers/fields/progress_bar_field_controller'
import RecordSelectorController from './controllers/record_selector_controller'
import ReloadBelongsToFieldController from './controllers/fields/reload_belongs_to_field_controller'
import ResourceEditController from './controllers/resource_edit_controller'
import ResourceIndexController from './controllers/resource_index_controller'
import ResourceShowController from './controllers/resource_show_controller'
import SearchController from './controllers/search_controller'
import SelectController from './controllers/select_controller'
import SelectFilterController from './controllers/select_filter_controller'
import SelfDestroyController from './controllers/self_destroy_controller'
import SidebarController from './controllers/sidebar_controller'
import SignOutController from './controllers/sign_out_controller'
import TableRowController from './controllers/table_row_controller'
import TabsController from './controllers/tabs_controller'
import TagsFieldController from './controllers/fields/tags_field_controller'
import TextFilterController from './controllers/text_filter_controller'
import TippyController from './controllers/tippy_controller'
import TiptapFieldController from './controllers/fields/tiptap_field_controller'
import ToggleController from './controllers/toggle_controller'
import TrixBodyController from './controllers/trix_body_controller'
import TrixFieldController from './controllers/fields/trix_field_controller'

// Special cases for controller registration names
const SPECIAL_CASES = {
  nested_form: 'avo-nested-form'
}

// Helper function to convert snake_case to kebab-case
function toKebabCase(str) {
  return str.replace(/_/g, '-')
}

// Controllers registry - automatically registers all controllers
const CONTROLLERS = [
  ['action', ActionController],
  ['actions_overflow', ActionsOverflowController],
  ['actions_picker', ActionsPickerController],
  ['attachments', AttachmentsController],
  ['boolean_filter', BooleanFilterController],
  ['card_filters', CardFiltersController],
  ['copy_to_clipboard', CopyToClipboardController],
  ['dashboard_card', DashboardCardController],
  ['date_time_filter', DateTimeFilterController],
  ['filter', FilterController],
  ['form', FormController],
  ['hidden_input', HiddenInputController],
  ['input_autofocus', InputAutofocusController],
  ['item_select_all', ItemSelectAllController],
  ['item_selector', ItemSelectorController],
  ['loading_button', LoadingButtonController],
  ['media_library_attach', MediaLibraryAttachController],
  ['media_library', MediaLibraryController],
  ['menu', MenuController],
  ['modal', ModalController],
  ['multiple_select_filter', MultipleSelectFilterController],
  ['nested_form', NestedFormController],
  ['panel_refresh', PanelRefreshController],
  ['per_page', PerPageController],
  ['preview', PreviewController],
  ['record_selector', RecordSelectorController],
  ['resource_edit', ResourceEditController],
  ['resource_index', ResourceIndexController],
  ['resource_show', ResourceShowController],
  ['search', SearchController],
  ['select', SelectController],
  ['select_filter', SelectFilterController],
  ['self_destroy', SelfDestroyController],
  ['sidebar', SidebarController],
  ['sign_out', SignOutController],
  ['table_row', TableRowController],
  ['tabs', TabsController],
  ['text_filter', TextFilterController],
  ['tippy', TippyController],
  ['toggle', ToggleController],
  ['trix_body', TrixBodyController],
  
  // Field controllers
  ['belongs_to_field', BelongsToFieldController],
  ['clear_input', ClearInputController],
  ['code_field', CodeFieldController],
  ['date_field', DateFieldController],
  ['easy_mde', EasyMdeController],
  ['key_value', KeyValueController],
  ['progress_bar_field', ProgressBarFieldController],
  ['reload_belongs_to_field', ReloadBelongsToFieldController],
  ['tags_field', TagsFieldController],
  ['tiptap_field', TiptapFieldController],
  ['trix_field', TrixFieldController],
]

// Auto-register all controllers
CONTROLLERS.forEach(([controllerName, ControllerClass]) => {
  const registrationName = SPECIAL_CASES[controllerName] || toKebabCase(controllerName)
  application.register(registrationName, ControllerClass)
})

// Custom controllers
