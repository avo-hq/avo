module Avo
  module Licensing
    class License
      attr_accessor :id
      attr_accessor :response
      attr_accessor :valid
      attr_accessor :payload

      def initialize(response)
        @response = response
        @id = response["id"]
        @valid = response["valid"]
        @payload = response["payload"]
      end

      def valid?
        valid
      end

      def invalid?
        !valid?
      end

      def pro?
        id == "pro"
      end

      def error
        @response["error"]
      end

      def properties
        @response.slice("valid", "id", "error").symbolize_keys
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

      alias_method :has, :can
      alias_method :lacks, :cant
    end
  end
end
