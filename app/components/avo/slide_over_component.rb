# frozen_string_literal: true

# Side-anchored slide-out UI shell with its own Turbo frame and Stimulus
# controller. Mirrors Avo::ModalComponent's slot/prop shape but is intentionally
# isolated: it lives behind Avo::SLIDE_OVER_FRAME_ID (not MODAL_FRAME_ID) and
# uses the `slide-over-open` body class (not `modal-open`) so the two surfaces
# can never visually collide.
#
# Mandatory scope for v1 is :ephemeral behavior; persistent slide-out is out of
# scope (no toggle/show-hide stimulus pair).
class Avo::SlideOverComponent < Avo::BaseComponent
  renders_one :heading
  renders_one :controls

  WIDTHS = %i[sm md lg].freeze

  prop :width, default: :md # :sm, :md, :lg
  prop :body_class
  prop :close_on_backdrop_click, default: true, reader: :public
  prop :behavior, default: :ephemeral # only :ephemeral is in scope for v1
  prop :show_close_button, default: true
  prop :class, default: ""
  prop :data, default: {}.freeze
  prop :hidden, default: false

  def after_initialize
    unless WIDTHS.include?(@width)
      raise ArgumentError, "Invalid width: #{@width.inspect}. Expected one of #{WIDTHS.inspect}."
    end

    unless @behavior == :ephemeral
      raise ArgumentError, "Only :ephemeral behavior is supported for SlideOverComponent."
    end
  end

  def stimulus_controller
    "slide-over"
  end

  def ctrl = stimulus_controller

  def has_header?
    heading? || @show_close_button
  end
end
