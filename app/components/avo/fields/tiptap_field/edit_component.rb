# frozen_string_literal: true

class Avo::Fields::TiptapField::EditComponent < Avo::Fields::EditComponent
  attr_reader :resource

  def initialize(**args)
    @resource = args[:resource]
    @resource_id = args[:resource_id]
    @resource_name = args[:resource_name]

    super(**args)
  end

  def resource_name
    @resource_name || resource&.singular_route_key
  end

  def resource_id
    @resource_id || resource&.record&.id
  end

  def tiptap_id
    if resource_name.present?
      "tiptap_#{resource_name}_#{@field.id}"
    elsif form.present?
      "tiptap_#{form.index}_#{@field.id}"
    end
  end

  def field_input_args
    super.merge(
      {
        class: classes("w-full hidden"),
        data: {
          tiptap_field_target: "input",
          **@field.get_html(:data, view: view, element: :input)
        },
        id: tiptap_id
      }
    )
  end
end
