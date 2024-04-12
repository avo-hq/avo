module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
    after_create :ensure_has_entry
  end

  def ensure_has_entry
    puts ["ensure_has_entry->", self, Current.user].inspect
    current_user = Current.user || User.find(37)
    self.entry = Entry.create! creator: current_user, entryable: self
  rescue => e
    puts ["e->", e].inspect
    # self.save
  end
  # def ensure_has_entry
  #   puts ["ensure_has_entry->", self].inspect
  #   Entry.create! entryable: self, creator: Current.user
  # end
end
