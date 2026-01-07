# frozen_string_literal: true

module Avo
  class ProfilePhoto < PhotoObject
    def key = :profile_photo

    def initials
      @resource.record_title.split(" ").map(&:first).join("").first(2).upcase
    end
  end
end
