import { application } from './application'

import ActionController from './controllers/action_controller'
import ActionsPickerController from './controllers/actions_picker_controller'
import AlertsController from './controllers/alerts_controller'
import AttachmentsController from './controllers/attachments_controller'
import BelongsToFieldController from './controllers/fields/belongs_to_field_controller'
import BooleanFilterController from './controllers/boolean_filter_controller'
import CodeFieldController from './controllers/fields/code_field_controller'
import CopyToClipboardController from './controllers/copy_to_clipboard_controller'
import DashboardCardController from './controllers/dashboard_card_controller'
import DateFieldController from './controllers/fields/date_field_controller'
import FilterController from './controllers/filter_controller'
import HiddenInputController from './controllers/hidden_input_controller'
import ItemSelectAllController from './controllers/item_select_all_controller'
import ItemSelectorController from './controllers/item_selector_controller'
import KeyValueController from './controllers/fields/key_value_controller'
import LoadingButtonController from './controllers/loading_button_controller'
import MenuController from './controllers/menu_controller'
import MobileController from './controllers/mobile_controller'
import ModalController from './controllers/modal_controller'
import MultipleSelectFilterController from './controllers/multiple_select_filter_controller'
import PerPageController from './controllers/per_page_controller'
import SearchController from './controllers/search_controller'
import SelectController from './controllers/select_controller'
import SelectFilterController from './controllers/select_filter_controller'
import SimpleMdeController from './controllers/fields/simple_mde_controller'
import TextFilterController from './controllers/text_filter_controller'
import TippyController from './controllers/tippy_controller'
import TogglePanelController from './controllers/toggle_panel_controller'
import TrixFieldController from './controllers/fields/trix_field_controller'

application.register('action', ActionController)
application.register('actions-picker', ActionsPickerController)
application.register('alerts', AlertsController)
application.register('attachments', AttachmentsController)
application.register('boolean-filter', BooleanFilterController)
application.register('copy-to-clipboard', CopyToClipboardController)
application.register('dashboard-card', DashboardCardController)
application.register('filter', FilterController)
application.register('hidden-input', HiddenInputController)
application.register('item-select-all', ItemSelectAllController)
application.register('item-selector', ItemSelectorController)
application.register('loading-button', LoadingButtonController)
application.register('menu', MenuController)
application.register('mobile', MobileController)
application.register('modal', ModalController)
application.register('multiple-select-filter', MultipleSelectFilterController)
application.register('per-page', PerPageController)
application.register('search', SearchController)
application.register('select', SelectController)
application.register('select-filter', SelectFilterController)
application.register('text-filter', TextFilterController)
application.register('tippy', TippyController)
application.register('toggle-panel', TogglePanelController)

// Field controllers
application.register('belongs-to-field', BelongsToFieldController)
application.register('code-field', CodeFieldController)
application.register('date-field', DateFieldController)
application.register('key-value', KeyValueController)
application.register('simple-mde', SimpleMdeController)
application.register('trix-field', TrixFieldController)
