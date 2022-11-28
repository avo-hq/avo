module Avo
  module Hosts
    class VisibilityHost < BaseHost
      option :parent_resource
      option :resource
      option :arguments

      # View is optional because in filter context the view is always :index
      option :view, optional: true
    end
  end
end
