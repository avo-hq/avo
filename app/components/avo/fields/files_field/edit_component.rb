# frozen_string_literal: true

class Avo::Fields::FilesField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
end
