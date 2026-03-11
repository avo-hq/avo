# frozen_string_literal: true

class Avo::FrameLoadFailedComponent < Avo::BaseComponent
  prop :frame, default: "this"
  prop :src
  prop :show_illustration, default: true
  prop :classes

  def document_cards
    %i[start center end]
  end
end
