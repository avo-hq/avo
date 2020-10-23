module Avo
  class License
    attr_accessor :id
    attr_accessor :response
    attr_accessor :valid

    def initialize(response)
      @response = response
      @id = response['id']
      @valid = response['valid']
    end

    def invalid?
      !valid?
    end

    def pro?
      id == 'pro'
    end

    def invalid_reason
      @response[:invalid_reason]
    end

    def properties
      @response.slice 'valid'
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
