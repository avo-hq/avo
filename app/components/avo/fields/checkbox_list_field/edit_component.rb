# frozen_string_literal: true

class Avo::Fields::CheckboxListField::EditComponent < Avo::Fields::EditComponent
  def initialize(...)
    super

    @data = @field.get_html(:data, view: view, element: :input)
    @style = @field.get_html(:style, view: view, element: :input)
    @form_scope = @form.object_name
    @options = @field.options
    @inline_search = @field.inline_search?
  end

  def checked?(id)
    stored_ids.include? @field.normalize_id(id)
  end

  def input_name
    @input_name ||= "#{@form_scope}[#{@field.id}][]"
  end

  def input_html_id(id)
    field_dom_id(id)
  end

  def inline_search?
    @inline_search && selectable_options.any?
  end

  def selectable_options
    @selectable_options ||= @options.select { |option| !@field.option_hint?(option) }
  end

  def more_records_hint
    @options.find { |option| @field.option_hint?(option) }
  end

  def checkbox_list_id
    @checkbox_list_id ||= field_dom_id(:checkbox_list)
  end

  def inline_search_input_id
    @inline_search_input_id ||= field_dom_id(:inline_search)
  end

  def checkbox_list_field_data
    return {} unless inline_search?

    {
      controller: "checkbox-list-field",
      action: "input->checkbox-list-field#filter keydown->checkbox-list-field#handleKeydown",
      checkbox_list_field_hidden_selections_one_value: t("avo.checkbox_list.hidden_selections.one"),
      checkbox_list_field_hidden_selections_other_value: t("avo.checkbox_list.hidden_selections.other")
    }
  end

  def inline_search_label
    t("avo.search.placeholder")
  end

  def inline_search_aria_label
    "#{inline_search_label} #{@field.name}"
  end

  private

  def stored_ids
    @stored_ids ||= normalize_values(effective_value)
  end

  def effective_value
    return submitted_value if submitted_value?

    Array(@field.value)
  end

  def submitted_value
    params[@form_scope][@field.id.to_s]
  end

  def submitted_value?
    params[@form_scope].present? && params[@form_scope].key?(@field.id.to_s)
  end

  def normalize_values(values)
    Array(values).filter_map { |value| @field.normalize_id(value) }
  end

  def field_dom_id(*parts)
    ([field_dom_id_prefix] + parts.map { |part| sanitize_id(part) }).join("_")
  end

  def field_dom_id_prefix
    @field_dom_id_prefix ||= [@form_scope, @field.id].map { |part| sanitize_id(part) }.join("_")
  end

  def sanitize_id(value)
    value.to_s.gsub(/[^a-zA-Z0-9\-:.]/, "_")
  end
end
