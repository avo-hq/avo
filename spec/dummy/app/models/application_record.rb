class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    alias_method :original_inspect, :inspect

    def inspect
      name
    end
  end
end
