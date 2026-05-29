# frozen_string_literal: true

class Avo::Fields::EditComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :form
  attr_reader :index
  attr_reader :kwargs
  attr_reader :multiple
  attr_reader :resource
  attr_reader :stacked
  attr_reader :view
  attr_reader :full_width

  def initialize(field: nil, resource: nil, index: 0, form: nil, stacked: nil, full_width: nil, multiple: false, autofocus: false, view: nil, **kwargs)
    @field = field
    @form = form
    @index = index
    @kwargs = kwargs
    @multiple = multiple
    @resource = resource
    @stacked = stacked
    # Honor an explicit `view:` kwarg (used by the bulk-update slide-out to propagate :bulk_edit).
    # Default to :edit so existing call sites (Action forms, regular edit/new flows) are unaffected.
    @view = view || Avo::ViewInquirer.new("edit")
    @autofocus = autofocus
    @full_width = full_width
  end

  # Returns true when this component is rendering in the bulk-update slide-out.
  # Field-edit subclasses (Boolean, BelongsTo) branch on this to swap their markup
  # (tri-state radio, include-blank "Unchanged" option, etc.).
  def bulk_edit?
    view.respond_to?(:bulk?) && view.bulk?
  end

  def classes(extra_classes = "")
    helpers.input_classes(
      "#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}",
      has_error: @field.record_errors.include?(@field.id),
      size: @field.size
    )
  end

  def render?
    !field.computed
  end

  # @param data [Hash] optional extra `data:` attributes that subclasses' templates need
  #   to put on the wrapper (e.g. `reload-belongs-to-field`, `tags-field`).
  #   They are MERGED into the base `data:` (which carries the bulk-update-field
  #   Stimulus wiring during a `:bulk_edit` view) so neither side clobbers the other.
  # @param overrides [Hash] any other top-level wrapper args to override / add.
  def field_wrapper_args(data: nil, **overrides)
    args = {
      field: field,
      form: form,
      index: index,
      resource: resource,
      stacked: stacked,
      full_width: full_width,
      view: view
    }

    # In the bulk-update slide-out, the wrapper needs a Stimulus controller that
    # snapshots the initial value and dispatches `bulk-update:field-changed` on
    # trusted user input. The wrapper component merges this `data:` into its
    # root element's data attributes.
    base_data = {}
    if bulk_edit?
      base_data = {
        controller: "bulk-update-field",
        "bulk-update-field-key-value": field.id.to_s
      }
    end

    # Merge caller-supplied data on top of base data. If both sides set
    # `controller:`, concatenate (Stimulus accepts space-separated controller lists).
    merged_data = base_data.dup
    if data.present?
      data.each do |key, value|
        if key.to_s == "controller" && merged_data[:controller].present?
          merged_data[:controller] = "#{merged_data[:controller]} #{value}"
        else
          merged_data[key] = value
        end
      end
    end

    args[:data] = merged_data if merged_data.present?
    args.merge!(overrides) if overrides.any?
    args
  end

  def disabled?
    field.is_readonly? || field.is_disabled?
  end
end
