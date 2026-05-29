# frozen_string_literal: true

# Per-field "current state" notice rendered below each field input in the
# bulk-update slide-out. Three modes per the visual-treatment table:
#
#   * :all_share   - 1 distinct value, muted neutral, "All N records have <field> = <value>"
#   * :sample_list - <= sample_threshold distinct values, tertiary tone, "N different values: a, b, c"
#   * :count_only  - > sample_threshold distinct values, accent tone, "N different values"
#
# The notice is keyed to the field's input via `aria-describedby` so AT users hear it.
class Avo::BulkUpdate::StatusNoticeComponent < Avo::BaseComponent
  MODES = %i[all_share sample_list count_only].freeze

  # `field` is an Avo::Fields::BaseField; used for the label and the input id.
  # `notice` is the hash produced by BulkUpdateController#notices_for_field:
  #
  #   { mode: :all_share, value: <single_value>, count: <total_records> }
  #   { mode: :sample_list, values: [...], count: <total_records> }
  #   { mode: :count_only,  distinct_count: <int>, count: <total_records> }
  prop :field
  prop :notice

  def after_initialize
    unless MODES.include?(@notice[:mode])
      raise ArgumentError, "Invalid notice mode: #{@notice[:mode].inspect}. Expected one of #{MODES.inspect}."
    end
  end

  def mode = @notice[:mode]

  def icon_name
    case mode
    when :all_share then "tabler/outline/check"
    when :sample_list then "tabler/outline/stack-2"
    when :count_only then "tabler/outline/alert-circle"
    end
  end

  def tone_class
    case mode
    when :all_share then "bulk-update-status-notice--muted"
    when :sample_list then "bulk-update-status-notice--tertiary"
    when :count_only then "bulk-update-status-notice--accent"
    end
  end

  # Stable id for aria-describedby. The field's input element should reference this id.
  def notice_id
    "bulk-update-status-notice-#{@field.id}"
  end

  def field_label
    @field.name
  end

  def total_count = @notice[:count]

  def distinct_count = @notice[:distinct_count]

  def sample_values = Array(@notice[:values])

  def all_share_value_label
    format_value(@notice[:value])
  end

  def sample_value_labels
    sample_values.map { |v| format_value(v) }.join(", ")
  end

  private

  # Stringify the value for display. Blank values get the localized "blank" label
  # so the notice doesn't render as "All 5 records have priority set to ."
  def format_value(value)
    return t("avo.bulk_update.status_notice.blank_value") if value.nil? || value == ""

    value.to_s
  end
end
