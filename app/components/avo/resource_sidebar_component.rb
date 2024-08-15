# frozen_string_literal: true

class Avo::ResourceSidebarComponent < Avo::BaseComponent
  prop :resource, _Nilable(Avo::BaseResource)
  prop :sidebar, _Nilable(Avo::Resources::Items::Sidebar)
  prop :index, _Nilable(Integer)
  prop :params, _Nilable(ActionController::Parameters)
  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :view, _Nilable(Symbol), reader: :public do |value|
    value&.to_sym
  end

  def render?
    Avo.license.has_with_trial(:resource_sidebar)
  end
end
