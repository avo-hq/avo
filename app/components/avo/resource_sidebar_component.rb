# frozen_string_literal: true

class Avo::ResourceSidebarComponent < Avo::BaseComponent
  prop :resource
  prop :sidebar
  prop :index
  prop :params
  prop :form
  prop :view, reader: :public
end
