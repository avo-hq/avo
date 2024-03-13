import { Avo } from './avo'

import ActionController from './controllers/action_controller'
import ActionsOverflowController from './controllers/actions_overflow_controller'
import ActionsPickerController from './controllers/actions_picker_controller'
import AttachmentsController from './controllers/attachments_controller'
import BelongsToFieldController from './controllers/fields/belongs_to_field_controller'
import BooleanFilterController from './controllers/boolean_filter_controller'
import CodeFieldController from './controllers/fields/code_field_controller'
import CopyToClipboardController from './controllers/copy_to_clipboard_controller'
import DashboardCardController from './controllers/dashboard_card_controller'
import DateFieldController from './controllers/fields/date_field_controller'
import EasyMdeController from './controllers/fields/easy_mde_controller'
import FilterController from './controllers/filter_controller'
import HiddenInputController from './controllers/hidden_input_controller'
import InputAutofocusController from './controllers/input_autofocus_controller'
import ItemSelectAllController from './controllers/item_select_all_controller'
import ItemSelectorController from './controllers/item_selector_controller'
import KeyValueController from './controllers/fields/key_value_controller'
import LoadingButtonController from './controllers/loading_button_controller'
import MenuController from './controllers/menu_controller'
import ModalController from './controllers/modal_controller'
import MultipleSelectFilterController from './controllers/multiple_select_filter_controller'
import PerPageController from './controllers/per_page_controller'
import PreviewController from './controllers/preview_controller'
import ProgressBarFieldController from './controllers/fields/progress_bar_field_controller'
import ReloadBelongsToFieldController from './controllers/fields/reload_belongs_to_field_controller'
import ResourceEditController from './controllers/resource_edit_controller'
import ResourceIndexController from './controllers/resource_index_controller'
import ResourceShowController from './controllers/resource_show_controller'
import SearchController from './controllers/search_controller'
import SelectController from './controllers/select_controller'
import SelectFilterController from './controllers/select_filter_controller'
import SelfDestroyController from './controllers/self_destroy_controller'
import SidebarController from './controllers/sidebar_controller'
import TabsController from './controllers/tabs_controller'
import TagsFieldController from './controllers/fields/tags_field_controller'
import TextFilterController from './controllers/text_filter_controller'
import TippyController from './controllers/tippy_controller'
import ToggleController from './controllers/toggle_controller'
import TrixFieldController from './controllers/fields/trix_field_controller'

Avo.registerController('action', ActionController)
Avo.registerController('actions-overflow', ActionsOverflowController)
Avo.registerController('actions-picker', ActionsPickerController)
Avo.registerController('attachments', AttachmentsController)
Avo.registerController('boolean-filter', BooleanFilterController)
Avo.registerController('copy-to-clipboard', CopyToClipboardController)
Avo.registerController('dashboard-card', DashboardCardController)
Avo.registerController('filter', FilterController)
Avo.registerController('hidden-input', HiddenInputController)
Avo.registerController('input-autofocus', InputAutofocusController)
Avo.registerController('item-select-all', ItemSelectAllController)
Avo.registerController('item-selector', ItemSelectorController)
Avo.registerController('loading-button', LoadingButtonController)
Avo.registerController('menu', MenuController)
Avo.registerController('modal', ModalController)
Avo.registerController('multiple-select-filter', MultipleSelectFilterController)
Avo.registerController('per-page', PerPageController)
Avo.registerController('preview', PreviewController)
Avo.registerController('resource-edit', ResourceEditController)
Avo.registerController('resource-index', ResourceIndexController)
Avo.registerController('resource-show', ResourceShowController)
Avo.registerController('search', SearchController)
Avo.registerController('select', SelectController)
Avo.registerController('select-filter', SelectFilterController)
Avo.registerController('self-destroy', SelfDestroyController)
Avo.registerController('sidebar', SidebarController)
Avo.registerController('tabs', TabsController)
Avo.registerController('text-filter', TextFilterController)
Avo.registerController('tippy', TippyController)
Avo.registerController('toggle', ToggleController)

// Field controllers
Avo.registerController('belongs-to-field', BelongsToFieldController)
Avo.registerController('code-field', CodeFieldController)
Avo.registerController('date-field', DateFieldController)
Avo.registerController('easy-mde', EasyMdeController)
Avo.registerController('key-value', KeyValueController)
Avo.registerController('progress-bar-field', ProgressBarFieldController)
Avo.registerController('reload-belongs-to-field', ReloadBelongsToFieldController)
Avo.registerController('tags-field', TagsFieldController)
Avo.registerController('trix-field', TrixFieldController)

// Custom controllers
