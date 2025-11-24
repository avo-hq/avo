class Avo::DiscreetInformation
  extend PropInitializer::Properties
  include ActionView::Helpers::TagHelper

  prop :resource, reader: :public

  delegate :record, :view, to: :resource

  def items
    Array.wrap(resource.class.discreet_information).map do |item|
      if item == :timestamps
        timestamp_item(item, as: :icon)
      elsif item == :timestamps_badge
        timestamp_item(item, as: :badge)
      elsif item == :id
        id_item(item, as: :key_value)
      elsif item == :id_text
        id_item(item, as: :text)
      else
        parse_payload(item)
      end
    end.compact
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

    {
      tooltip: tag.div([created_at_tag, updated_at_tag].compact.join(tag.br), style: "text-align: right;"),
      icon: "heroicons/outline/clock",
      as: as
    }
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
      tooltip: Avo::ExecutionContext.new(target: item[:tooltip], **args).handle,
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
