# frozen_string_literal: true

class Avo::Fields::FileField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
end
