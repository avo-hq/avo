module Avocado
  module ResourceFields
    @@fields = []
    # include TextField

    # def get_fields
    #   @@fields
    # end

      # def name
      #   abort 'nname'.inspect
      # end

      # def url
      #   @@url
      # end

    def fields(&block)
      # abort block.call.args.first.inspect
      # abort block.call.inspect
      # self.new(block.call.name)
      # abort self.inspect
      # abort block.call.inspect
      # @@fields.push block.call
      yield
      # @f.push block.call
      # yield
    end

    def get_fields
      @@fields
    end

    # def id(*args)
    #   # abort args.inspect
    #   # args
    #   Avocado::ResourceFields::TextField::new(*args)
    # end

    def text(name)
      # abort args.inspect
      # abort field.inspect
      @@fields.push Avocado::ResourceFields::TextField::new(name)
      # name
    end

    def id(name)
      # abort args.inspect
      # abort field.inspect
      @@fields.push Avocado::ResourceFields::IdField::new(name)
      # name
    end

    def hydrate_resource(resource)

    end
  end
end
