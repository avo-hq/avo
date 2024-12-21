module Avo
  module Fields
    class MarkdownField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
        @height = args[:height].present? ? args[:height].to_s : 'auto'
        @upload_url = args[:upload_url].present? ? args[:upload_url] : direct_uploads_url
        @image_upload =
          args[:image_upload].present? ? args[:image_upload] : false
        @spell_checker =
          args[:spell_checker].present? ? args[:spell_checker] : false
        @options = {
          spell_checker: @spell_checker,
          always_show: @always_show,
          image_upload: @image_upload,
          upload_url: get_upload_url,

          height: @height
        }
      end

      private

      def direct_uploads_url
        "/rails/active_storage/direct_uploads"
      end
    end
  end
end
