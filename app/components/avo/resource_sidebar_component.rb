# frozen_string_literal: true

class Avo::ResourceSidebarComponent < Avo::BaseComponent
  prop :resource, _Nilable(Avo::BaseResource), reader: :public
  prop :sidebar, _Nilable(Avo::Resources::Items::Sidebar), reader: :public
  prop :index, _Nilable(Integer), reader: :public
  prop :params, _Nilable(ActionController::Parameters), reader: :public
  prop :form, _Nilable(ActionView::Helpers::FormBuilder), reader: :public
  prop :view, _Nilable(Symbol), reader: :public do |value|
    value&.to_sym
  end

  def render?
    Avo.license.has_with_trial(:resource_sidebar)
  end
end
