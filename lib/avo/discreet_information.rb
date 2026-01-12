class Avo::DiscreetInformation
  extend PropInitializer::Properties
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper

  prop :resource, reader: :public

  delegate :record, :view, to: :resource

  def items
    Array.wrap(resource.class.discreet_information).map do |item|
      if item == :timestamps
        timestamp_item(item, as: :icon)
      elsif item == :timestamps_key_value
        timestamp_item(item, as: :key_value)
      elsif item == :id
        id_item(item, as: :key_value)
      elsif item == :id_badge
        id_item(item, as: :badge)
      else
        parse_payload(item)
      end
    end.flatten.compact
  end

  private

  def id_item(item, as: :text)
    text = record.id
    if as == :key_value
      key = "ID"
    end

    {
      text: text,
      key: key,
      as: as
    }
  end

  def timestamp_item(item, as: :text)
    return if record.created_at.blank? && record.updated_at.blank?

    time_format = "%Y-%m-%d %H:%M:%S"
    created_at = record.created_at.strftime(time_format)
    updated_at = record.updated_at.strftime(time_format)

    created_at_tag = if record.created_at.present?
      I18n.t("avo.created_at_timestamp", created_at:)
    end

    updated_at_tag = if record.updated_at.present?
      I18n.t("avo.updated_at_timestamp", updated_at:)
    end

    if as == :key_value
      # Older versions of rails don't have the relative_time_in_words helper
      if defined?(relative_time_in_words)
        created_at_text = relative_time_in_words(record.created_at)
        updated_at_text = relative_time_in_words(record.updated_at)
      else
        created_at_text = created_at
        updated_at_text = updated_at
      end

      [
        {
          text: created_at_text,
          key: I18n.t("avo.created_at"),
          as: :key_value,
          title: created_at
        },
        {
          text: updated_at_text,
          key: I18n.t("avo.updated_at"),
          as: :key_value,
          title: updated_at
        }
      ]
    elsif as == :icon
      {
        title: tag.div([created_at_tag, updated_at_tag].compact.join(tag.br), style: "text-align: right;"),
        icon: "heroicons/outline/clock",
        as:
      }
    end
  end

  def parse_payload(item)
    return unless item.is_a?(Hash)

    args = {
      record:,
      resource:,
      view:
    }

    visible = item[:visible].nil? || Avo::ExecutionContext.new(target: item[:visible], **args).handle

    return unless visible

    {
      title: Avo::ExecutionContext.new(target: item[:title], **args).handle,
      icon: Avo::ExecutionContext.new(target: item[:icon], **args).handle,
      url: Avo::ExecutionContext.new(target: item[:url], **args).handle,
      target: Avo::ExecutionContext.new(target: item[:target], **args).handle,
      data: Avo::ExecutionContext.new(target: item[:data], **args).handle,
      text: Avo::ExecutionContext.new(target: item[:text], **args).handle,
      key: Avo::ExecutionContext.new(target: item[:key], **args).handle,
      as: Avo::ExecutionContext.new(target: item[:as], **args).handle
    }
  end
end
