require_relative './field'

module Avocado
  module Fields
    class HasManyField < Field
      def initialize(*args)
        super

        @component = 'belongs-to-field'
      end

      def fetch_for_resource(resource, view)
        return
        abort view.inspect
        return if [:create, :index].include? view

        fields = super(resource)

        fields[:is_relation] = true
        # abort "Avocado::Resources::#{name.to_s.singularize}".inspect
        # abort resource.inspect
        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name.to_s.singularize}".safe_constantize }
        # abort target_resource.name.underscore.inspect
        # abort target_resource.name.underscore.to_s.pluralize.inspect
        relation_model = resource.public_send(target_resource.name.underscore.to_s.pluralize)
        # abort relation_model.all.inspect
        # fields[:value] = relation_model[target_resource.title]

        fields
      end
    end
  end
end
