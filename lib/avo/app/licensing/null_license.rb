module Avo
  class NullLicense < License
    def initialize
      super(id: 'solo', valid: true)
    end
  end
end
