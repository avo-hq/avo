# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Concerns::ChecksShowAuthorization

  attr_writer :header_fields

  prop :resource, reader: :public
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :actions
  prop :fields
  prop :header_fields
  prop :index
  prop :row_selector_checked, default: false

  def resource_controls_component
    Avo::Index::ResourceControlsComponent.new(
      resource: @resource,
      reflection: @reflection,
      parent_record: @parent_record,
      parent_resource: @parent_resource,
      view_type: :table,
      actions: @actions
    )
  end

  def click_row_to_view_record
    Avo.configuration.click_row_to_view_record && can_view?
  end

  # The render context for `row_options` blocks. Derived from `@reflection`
  # rather than passed as a prop, matching the precedent in
  # `Avo::Views::ResourceIndexComponent` and `Avo::ResourceComponent`.
  def view
    @reflection.present? ? :has_many : :index
  end

  # Final attributes applied to the <tr>. User-supplied `row_options` are
  # merged in via Avo::TableRowOptions; evaluated at render time so each
  # request re-evaluates regardless of `cache_resources_on_index_view`.
  def merged_tr_attributes
    Avo::TableRowOptions.merge(
      avo_attributes: default_tr_attributes,
      user_options: @resource.class.table_view&.dig(:row_options),
      record: @resource.record,
      resource: @resource,
      view: view
    )
  end

  private

  def default_tr_attributes
    {
      id: "#{self.class.to_s.underscore}_#{@resource.record_param}",
      class: class_names("table-row group z-21", {"cursor-pointer": click_row_to_view_record}),
      data: default_tr_data
    }
  end

  def default_tr_data
    data = {
      index: @index,
      component_name: component_name,
      resource_name: @resource.class.to_s,
      record_id: @resource.record_param
    }
    data.merge!(click_to_view_data_attributes) if click_row_to_view_record
    data.merge!(item_selector_data_attributes(@resource, controller: class_names("table-row": click_row_to_view_record)))
    data.merge!(try(:drag_reorder_item_data_attributes) || {})
    data
  end

  def click_to_view_data_attributes
    {
      visit_path: helpers.resource_show_path(
        resource: @resource,
        parent_resource: @parent_resource,
        parent_record: @parent_record,
        parent_or_child_resource: parent_or_child_resource
      ),
      action: "click->table-row#visitRecord keydown.enter->table-row#visitRecord keydown.space->table-row#visitRecord mouseenter->table-row#mouseEntered mouseleave->table-row#mouseLeft"
    }
  end
end
