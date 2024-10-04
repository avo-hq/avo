# frozen_string_literal: true

class Avo::Index::ResourceGridComponent < Avo::BaseComponent
  prop :resources
  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :actions, reader: :public
end
