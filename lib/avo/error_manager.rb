module Avo
  class ErrorManager
    class << self
      def build
        new
      end
    end

    attr_reader :errors

    alias_method :all, :errors

    def initialize
      @errors = []
    end

    def add(error)
      @errors << error
    end

    def has_errors?
      @errors.present?
    end

    def render?
      has_errors?
    end
  end
end
