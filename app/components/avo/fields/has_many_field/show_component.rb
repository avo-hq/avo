# frozen_string_literal: true

class Avo::Fields::HasManyField::ShowComponent < Avo::Fields::ShowComponent
  include Turbo::FramesHelper
  include Avo::Fields::Concerns::FrameLoading
end
