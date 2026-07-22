module Avo
  module Concerns
    module HasTranslatableTitle
      def title
        default = resolved_default_title
        key = translation_key(default:)

        return default if key.blank?

        I18n.t(key, default:)
      end

      def translation_key(default: resolved_default_title)
        @translation_key.presence || resource_translation_key(default)
      end

      private

      def resolved_default_title
        Avo::ExecutionContext.new(
          target: @title,
          resource:,
          record: resource&.record,
          view:
        ).handle
      end

      def resource_translation_key(default)
        return if resource.blank? || default.blank?

        key = default.to_s.parameterize(separator: "_")
        return if key.blank?

        "#{resource.translation_key}.#{title_translation_scope}.#{key}"
      end
    end
  end
end
