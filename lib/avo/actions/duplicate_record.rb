# frozen_string_literal: true

module Avo
  module Actions
    class DuplicateRecord < Avo::BaseAction
      self.name = -> { I18n.t("avo.duplicate_record", default: "Duplicate") }
      self.no_confirmation = true
      self.visible = -> { view.show? || view.index? }

      class << self
        def duplicate_config_for(resource_class)
          resource_class.try(:duplicate_config) || {}
        end
      end

      def handle(records:, **args)
        record = records.first

        if record.blank?
          error I18n.t("avo.no_record_to_duplicate", default: "No record to duplicate")
          return
        end

        config = self.class.duplicate_config_for(@resource.class)
        new_record = duplicate_record(record, config)

        if new_record.save
          succeed I18n.t("avo.record_duplicated", default: "Record duplicated successfully")
          reload
        else
          error I18n.t("avo.duplicate_failed", default: "Failed to duplicate: %{errors}") % {
            errors: new_record.errors.full_messages.join(", ")
          }
        end
      end

      private

      def duplicate_record(record, config)
        new_record = record.dup

        exclude_fields = Array(config[:exclude])
        exclude_fields.each do |field|
          new_record.send(:"#{field}=", nil) if new_record.respond_to?(:"#{field}=")
        end

        title_field = config[:title_field] || detect_title_field(record)
        if title_field && new_record.respond_to?(:"#{title_field}=")
          suffix = config[:title_suffix] || " Copy"
          original_value = record.send(title_field)
          new_record.send(:"#{title_field}=", "#{original_value}#{suffix}") if original_value.present?
        end

        defaults = config[:defaults] || {}
        defaults.each do |field, value|
          next unless new_record.respond_to?(:"#{field}=")

          resolved_value = value.respond_to?(:call) ? value.call(record) : value
          new_record.send(:"#{field}=", resolved_value)
        end

        copy_attachments(record, new_record, config)

        new_record
      end

      def copy_attachments(original, duplicate, config)
        return unless defined?(ActiveStorage)
        return unless original.class.respond_to?(:reflect_on_all_attachments)

        attachments_config = config[:copy_attachments]
        return if attachments_config == false

        attachments_to_copy = if attachments_config.is_a?(Array)
          attachments_config.map(&:to_sym)
        elsif attachments_config == true || attachments_config.nil?
          original.class.reflect_on_all_attachments.map(&:name)
        else
          []
        end

        attachments_to_copy.each do |attachment_name|
          reflection = original.class.reflect_on_attachment(attachment_name)
          next unless reflection

          if reflection.macro == :has_one_attached
            copy_single_attachment(original, duplicate, attachment_name)
          elsif reflection.macro == :has_many_attached
            copy_multiple_attachments(original, duplicate, attachment_name)
          end
        end
      end

      def copy_single_attachment(original, duplicate, name)
        attachment = original.send(name)
        return unless attachment.attached?

        duplicate.send(name).attach(
          io: StringIO.new(attachment.download),
          filename: attachment.filename.to_s,
          content_type: attachment.content_type
        )
      end

      def copy_multiple_attachments(original, duplicate, name)
        attachments = original.send(name)
        return unless attachments.attached?

        attachments.each do |attachment|
          duplicate.send(name).attach(
            io: StringIO.new(attachment.download),
            filename: attachment.filename.to_s,
            content_type: attachment.content_type
          )
        end
      end

      def detect_title_field(record)
        %i[name title label subject].find do |f|
          record.respond_to?(f) && record.send(f).present?
        end
      end
    end
  end
end
