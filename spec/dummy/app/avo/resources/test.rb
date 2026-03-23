# frozen_string_literal: true

class Avo::Resources::Test < Avo::BaseResource
  self.title = :name
  self.default_sort_column = :id
  self.default_sort_direction = :asc

  def fields
    field :id, as: :id
    field :name, as: :text
  end
end
