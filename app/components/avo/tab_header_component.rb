class Avo::TabHeaderComponent < Avo::BaseComponent
  prop :title
  prop :description

  def render?
    (@title || @description).present?
  end
end
