class Avo::DiscreetInformation
  extend PropInitializer::Properties
  include ActionView::Helpers::TagHelper

  prop :resource, reader: :public

  delegate :record, :view, to: :resource

  def items
    Array.wrap(resource.class.discreet_information).map do |item|
      if item == :timestamps
        timestamp_item(item, as: :text)
      elsif item == :timestamps_badge
        timestamp_item(item, as: :badge)
      elsif item == :id
        id_item(item, as: :text)
      elsif item == :id_badge
        id_item(item, as: :badge)
      else
        parse_payload(item)
      end
    end
  end

  private

  def id_item(item, as: :text)
    DiscreetInformationItem.new(
      label: "ID: #{record.id}",
      as:
    )
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

    DiscreetInformationItem.new(
      tooltip: tag.div([created_at_tag, updated_at_tag].compact.join(tag.br), style: "text-align: right;"),
      icon: "heroicons/outline/clock",
      as:
    )
  end

  def parse_payload(item)
    return unless item.is_a?(Hash)

    args = {
      record:,
      resource:,
      view:
    }

    DiscreetInformationItem.new(
      tooltip: Avo::ExecutionContext.new(target: item[:tooltip], **args).handle,
      icon: Avo::ExecutionContext.new(target: item[:icon], **args).handle,
      url: Avo::ExecutionContext.new(target: item[:url], **args).handle,
      url_target: Avo::ExecutionContext.new(target: item[:url_target], **args).handle,
      data: Avo::ExecutionContext.new(target: item[:data], **args).handle,
      label: Avo::ExecutionContext.new(target: item[:label], **args).handle,
      as: Avo::ExecutionContext.new(target: item[:as], **args).handle,
      visible: Avo::ExecutionContext.new(target: item[:visible], **args).handle
    )
  end

  DiscreetInformationItem = Struct.new(:tooltip, :icon, :url, :url_target, :data, :label, :as, :visible, keyword_init: true) unless defined?(DiscreetInformationItem)
end
