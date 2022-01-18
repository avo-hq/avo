require 'rails/generators'

module Generators
  module Avo
    class CardGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      class_option :type, type: :string
      class_option :sample, type: :boolean

      namespace 'avo:card'
      desc 'Add an Avo card for your dashboard.'

      def handle
        case options[:type]
        when 'metric'
          type = 'metric'
        when 'chartkick'
          type = 'chartkick'
        when 'partial'
          type = 'partial'
        else
          type = 'metric'
        end

        if options[:sample]
          template "cards/#{type}_card_sample.tt",
                   "app/avo/cards/#{name.underscore}.rb"
        else
          template "cards/#{type}_card.tt", "app/avo/cards/#{name.underscore}.rb"
        end

        if type == 'partial'
        template "cards/#{type}_card_partial.tt", "app/views/avo/cards/_#{name.underscore}.html.erb"
        end
      end
    end
  end
end
