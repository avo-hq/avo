module Avo
  class NullLicense < License
    def initialize(response)
      super(response)
      @id = 'community'
      @valid = true
    end
  end
end
