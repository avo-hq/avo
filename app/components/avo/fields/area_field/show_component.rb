# frozen_string_literal: true

class Avo::Fields::AreaField::ShowComponent < Avo::Fields::ShowComponent
  delegate :area_map, to: :helpers
end
