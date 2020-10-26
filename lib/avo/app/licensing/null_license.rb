module Avo
  class NullLicense < License
    def initialize(response = nil)
      response ||= {
        id: 'community',
        valid: true,
      }

      super(response)
    end
  end
end
