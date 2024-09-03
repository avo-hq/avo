# frozen_string_literal: true

class Avo::Index::ResourceGridComponent < Avo::BaseComponent
  prop :resources, _Array(_Nilable(Avo::BaseResource))
  prop :resource, _Nilable(Avo::BaseResource)
  prop :reflection, _Nilable(ActiveRecord::Reflection::AbstractReflection)
  prop :parent_record, _Nilable(_Any)
  prop :parent_resource, _Nilable(Avo::BaseResource)
  prop :actions, _Nilable(_Array(Avo::BaseAction)), reader: :public
end
