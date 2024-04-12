class Activity < ApplicationRecord
  include Entryable

  def title = name
end
