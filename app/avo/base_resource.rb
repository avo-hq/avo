module Avo
  class BaseResource < Avo::Resources::Base
    abstract_resource!
    # Users can override this class to add custom methods for all resources.
  end
end
