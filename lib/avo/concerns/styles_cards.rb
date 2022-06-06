module Avo
  module Concerns
    module StylesCards
      extend ActiveSupport::Concern

      included do
        class_attribute :cols, default: 1
        class_attribute :rows, default: 1

        def card_classes
          result = ""

          # Writing down the classes so TailwindCSS knows not to purge them
          classes_for_cols = {
            1 => " sm:col-span-1",
            2 => " sm:col-span-2",
            3 => " sm:col-span-3",
            4 => " sm:col-span-4",
            5 => " sm:col-span-5",
            6 => " sm:col-span-6"
          }

          classes_for_rows = {
            1 => " sm:row-span-1 min-h-[8rem]",
            2 => " sm:row-span-2 min-h-[16rem]",
            3 => " sm:row-span-3 min-h-[24rem]",
            4 => " sm:row-span-4 min-h-[32rem]",
            5 => " sm:row-span-5 min-h-[40rem]",
            6 => " sm:row-span-6 min-h-[48rem]",
          }

          result += classes_for_cols[cols.to_i] if classes_for_cols[cols.to_i].present?
          result += classes_for_rows[rows.to_i] if classes_for_rows[rows.to_i].present?

          result
        end

        def cols
          @cols || self.class.cols
        end

        def rows
          @rows || self.class.rows
        end
      end
    end
  end
end
