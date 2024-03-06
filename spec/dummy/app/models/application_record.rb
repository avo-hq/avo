class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include Hashid::Rails
end
