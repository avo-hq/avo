class Avo::DiscreetInformation
  extend PropInitializer::Properties

  prop :resource, reader: :public

  delegate :record, :view, to: :resource

  def items
    @items ||= Array.wrap(resource.class.discreet_information.dup).map do |item|
      if item == :timestamps
        timestamp_item(item)
      else
        parse_payload(item)
      end
    end
  end

  private

  def timestamp_item(item)
    time_format = "%Y-%m-%d %H:%M:%S"
    created_at = record.created_at.strftime(time_format)
    updated_at = record.updated_at.strftime(time_format)

    DiscreetInformationItem.new(
      tooltip: I18n.t('avo.discreet_information_timestamps_html', created_at:, updated_at:),
      icon: "heroicons/outline/clock"
    )
  end

  def parse_payload(item)
    if item.is_a?(Hash)
      tooltip = item.delete(:tooltip)
      icon = item.delete(:icon)
      url = item.delete(:url)
      url_target = item.delete(:url_target)
      label = item.delete(:label)

      DiscreetInformationItem.new(
        tooltip: Avo::ExecutionContext.new(target: tooltip, record: record, resource: self, view: view).handle,
        icon: Avo::ExecutionContext.new(target: icon, record: record, resource: self, view: view).handle,
        url: Avo::ExecutionContext.new(target: url, record: record, resource: self, view: view).handle,
        url_target: Avo::ExecutionContext.new(target: url_target, record: record, resource: self, view: view).handle,
        label: Avo::ExecutionContext.new(target: label, record: record, resource: self, view: view).handle,
      )
    end
  end

  DiscreetInformationItem = Struct.new(:tooltip, :icon, :url, :url_target, :label, keyword_init: true) unless defined?(DiscreetInformationItem)
end
