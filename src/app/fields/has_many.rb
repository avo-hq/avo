require_relative './field'

module Avocado
  module Fields
    class HasManyField < Field
      def initialize(*args)
        super

        @component = 'has-many-field'
      end

      def fetch_for_resource(resource, view)
        return if [:create, :index].include? view

        fields = super(resource)

        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name.to_s.singularize}".safe_constantize }
        # relation_model = resource.public_send(target_resource.underscore_name.to_s.pluralize)

        fields
      end
    end
  end
end
