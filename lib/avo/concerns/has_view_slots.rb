module Avo
  module Concerns
    module HasViewSlots
      extend ActiveSupport::Concern

      REGIONS = {
        index: %i[cards header title toolbar collection records pagination].freeze,
        show: %i[cards header title controls body].freeze,
        edit: %i[cards header title controls body form].freeze,
        new: %i[cards header title controls body form].freeze,
        form: %i[cards header title controls body form].freeze
      }.freeze

      included do
        REGIONS.each_key do |view|
          class_attribute :"#{view}_slots", default: {}.freeze, instance_writer: false
          class_attribute :"#{view}_slot_replacements", default: {}.freeze, instance_writer: false
        end
      end

      class_methods do
        REGIONS.each_key do |view|
          define_method(:"#{view}_slot") do |position, replace: false, &block|
            view_slot(view, position, replace: replace, &block)
          end
        end

        def view_slot(view, position, replace: false, &block)
          regions = REGIONS[view]
          unless regions
            raise ArgumentError, "Unsupported slot view #{view.inspect}. Supported views: #{REGIONS.keys.join(", ")}"
          end

          positions = replace ? regions : regions.flat_map { |region| [:"before_#{region}", :"after_#{region}"] }
          unless positions.include?(position)
            raise ArgumentError, "Unknown #{view} slot #{position.inspect} for replace: #{replace}. Choose from: #{positions.join(", ")}"
          end
          raise ArgumentError, "view_slot requires a block" unless block

          if replace
            replacements = public_send(:"#{view}_slot_replacements")
            if replacements.dig(position, :owner) == self
              raise ArgumentError, "#{view.to_s.capitalize} slot #{position.inspect} already has a replacement on #{self}"
            end

            public_send(:"#{view}_slot_replacements=", replacements.merge(position => {owner: self, block: block}.freeze).freeze)
          else
            slots = public_send(:"#{view}_slots")
            public_send(:"#{view}_slots=", slots.merge(position => [*slots[position], block].freeze).freeze)
          end
        end
      end
    end
  end
end
