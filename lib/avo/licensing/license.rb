module Avo
  module Licensing
    class License
      attr_accessor :id, :response, :valid, :payload

      def initialize(response = {})
        @response = response
        @id = 'advanced'
        @valid = true
        @payload = response['payload']
      end

      def valid?
        valid
      end

      def invalid?
        !valid?
      end

      def pro?
        id == 'pro'
      end

      def advanced?
        id == 'advanced'
      end

      def error
        @response['error']
      end

      def properties
        @response.slice('valid', 'id', 'error').symbolize_keys
      end

      def abilities
        []
      end

      def can(ability)
        abilities.include? ability
      end

      def cant(ability)
        !can ability
      end

      alias has can
      alias lacks cant

      # Returns if has ability and if is a valid license or app is in development.
      def has_with_trial(ability)
        return can(ability) && valid? if Rails.env.production?

        true
      end

      # Returns if lacks ability and if is a valid license or app is in development.
      def lacks_with_trial(ability)
        !has_with_trial ability
      end

      def name
        if id.present?
          id.humanize
        else
          self.class.to_s.split('::').last.underscore.humanize.gsub ' license', ''
        end
      end
    end
  end
end
