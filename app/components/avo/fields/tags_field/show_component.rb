# frozen_string_literal: true

# require_relative 'item_labels'

class Avo::Fields::TagsField::ShowComponent < Avo::Fields::ShowComponent
  include Avo::Fields::Concerns::ItemLabels
end
