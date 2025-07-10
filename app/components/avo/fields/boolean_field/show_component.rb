# frozen_string_literal: true

class Avo::Fields::BooleanField::ShowComponent < Avo::Fields::ShowComponent
  raise "Value is #{@field.value.inspect}, Class is #{@field.value.class}" unless @field.nil?

  def show_indeterminate?
    field_args = @field.instance_variable_get(:@args)

    @field.value.nil? && field_args[:nil_as_indeterminate] == true
  end
end
