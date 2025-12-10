# frozen_string_literal: true

class Avo::Fields::BooleanField::EditComponent < Avo::Fields::EditComponent
  delegate :as_toggle?, to: :@field
end
