# frozen_string_literal: true

# R13 K-of-N banner for the bulk-update slide-out.
#
# Three render paths:
#   * authorized == 0                      -> "No records editable" notice.
#   * authorized < total                   -> "Updating K of N. (N-K) excluded." line.
#   * authorized == total (no exclusions)  -> single "Updating N of N" line, no exclusion notice.
#
# A separate `:cap_exceeded` and `:n_too_small` variant render the corresponding
# error frames (used when the controller bails before instantiating the form).
class Avo::BulkUpdate::BannerComponent < Avo::BaseComponent
  VARIANTS = %i[default cap_exceeded n_too_small no_records_editable].freeze

  prop :authorized_count, default: 0
  prop :total_count, default: 0
  prop :max_records, default: nil
  prop :variant, default: :default

  def after_initialize
    unless VARIANTS.include?(@variant)
      raise ArgumentError, "Invalid variant: #{@variant.inspect}. Expected one of #{VARIANTS.inspect}."
    end
  end

  # The "no editable records" path is rendered as a variant too so the controller
  # has one component for every error/success banner shape.
  def variant
    return :no_records_editable if @variant == :default && @authorized_count.zero?

    @variant
  end

  def excluded_count
    [@total_count - @authorized_count, 0].max
  end

  def show_exclusion_line?
    variant == :default && excluded_count.positive?
  end

  def icon_name
    case variant
    when :cap_exceeded then "tabler/outline/alert-triangle"
    when :n_too_small then "tabler/outline/alert-triangle"
    when :no_records_editable then "tabler/outline/alert-triangle"
    else "tabler/outline/info-circle"
    end
  end

  # Maps to a BEMCSS modifier that drives token color (accent vs caution).
  def tone_class
    case variant
    when :default then "bulk-update-banner--accent"
    else "bulk-update-banner--caution"
    end
  end
end
