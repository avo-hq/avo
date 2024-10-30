# frozen_string_literal: true

class Avo::ResourceSidebarComponent < Avo::BaseComponent
  prop :resource
  prop :sidebar
  prop :index
  prop :params
  prop :form
  prop :view, reader: :public

  def render?
    Avo.license.has_with_trial(:resource_sidebar)
  end
end
