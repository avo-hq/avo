# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :field
  prop :form
  prop :view, default: Avo::ViewInquirer.new(:show).freeze
end
