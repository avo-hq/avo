# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :field
  prop :form
  prop :view, default: Avo::ViewInquirer.new(:show).freeze

  def suggestions
    @suggestions ||= @view.form? ? @field.suggestions : {}
  end

  # Unique per render so two key-value fields on one page never share a listbox id
  def suggestions_id
    @suggestions_id ||= "#{@field.id}-suggestions-#{SecureRandom.hex(4)}"
  end
end
