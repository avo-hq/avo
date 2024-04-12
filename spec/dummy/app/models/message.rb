class Message < ApplicationRecord
  include Entryable

  def title = subject
end
