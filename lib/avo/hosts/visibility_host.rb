module Avo
  module Hosts
    class VisibilityHost < BaseHost
      option :parent_model
      option :parent_resource
      option :resource
      option :options, optional: true #@todo: rm optional after implement options on actions.

      # View is optional because in filter context the view is always :index
      option :view, optional: true
    end
  end
end
