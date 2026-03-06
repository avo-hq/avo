# frozen_string_literal: true

class Avo::UI::FileUploadItemComponent < Avo::BaseComponent
  prop :title
  prop :size_label
  prop :progress, default: 0
  prop :classes
  prop :state, default: :default # :uploading, :complete, :error, :failed after we wull implement the states dynamically

  def show_progress?
    @progress.to_i > 0 || @state != :default
  end

  def progress_percentage
    @progress.to_i.clamp(0, 100)
  end
end
