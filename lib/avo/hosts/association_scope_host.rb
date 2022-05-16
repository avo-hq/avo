module Avo
  module Hosts
    class AssociationScopeHost < BaseHost
      option :parent
      option :grandparent
      option :query
    end
  end
end
