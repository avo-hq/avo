module Avo
  module Fields
    class HasOneField < Field
      attr_accessor :relation_method
      attr_accessor :display

      def initialize(name, **args, &block)
        @defaults = {
          updatable: true,
          partial_name: 'has-one-field',
        }

        super(name, **args, &block)

        hide_on :new

        @placeholder = I18n.t 'avo.choose_an_option'

        @relation_method = name.to_s.parameterize.underscore
        @display = args[:display].present? ? args[:display] : :index
      end

      def has_own_panel?
        true
      end

      def label
        value.send(target_resource.title)
      end

      def resource
        target_resource
      end

      # def model
      #   # value
      #   # target_resource.model_class.find 123
      # end

      def frame_name
        "#{self.class.name.demodulize.to_s.underscore}_#{id}_#{target_resource.model_class.to_s.underscore}"
      end

      def frame_url
        if @display == :index
          "#{Avo.configuration.root_path}/resources/#{target_resource.model_class.model_name.route_key}?frame_name=#{frame_name}&via_relation=has_one&via_relationship=#{id}&via_resource_name=#{@resource.model_class}&via_resource_id=#{@model.id}"
        else
          "#{Avo.configuration.root_path}/resources/#{target_resource.model_class.model_name.route_key}/#{value.id}?frame_name=#{frame_name}&via_relation=has_one&via_relationship=#{id}"
        end
      end

      private
        def target_resource
          if @model._reflections[id.to_s].klass.present?
            App.get_resource_by_model_name @model._reflections[id.to_s].klass.to_s
          elsif @model._reflections[id.to_s].options[:class_name].present?
            App.get_resource_by_model_name @model._reflections[id.to_s].options[:class_name]
          else
            App.get_resource_by_name id.to_s
          end
        end




      # def hydrate_field(fields, model, resource, view)
      #   target_resource = get_related_resource(resource)
      #   fields[:relation_class] = target_resource.class.to_s

      #   relation_model = model.public_send(@relation_method)

      #   if relation_model.present?
      #     relation_model = model.public_send(@relation_method)
      #     fields[:value] = relation_model.send(target_resource.title)
      #     fields[:database_value] = relation_model[:id]
      #   end

      #   # Populate the options on show and edit
      #   fields[:options] = []

      #   if [:edit, :new].include? view
      #     fields[:options] = target_resource.model.all.map do |model|
      #       {
      #         value: model.id,
      #         label: model.send(target_resource.title)
      #       }
      #     end
      #   end

      #   fields[:plural_name] = target_resource.plural_name

      #   fields
      # end

      # def get_related_resource(resource)
      #   class_name = resource.model.reflections[name.to_s.downcase].class_name
      #   App.get_resources.find { |r| r.class == "Avo::Resources::#{class_name}".safe_constantize }
      # end

      def fill_field(model, key, value)
        puts ['in fill_field->', model, key, value].inspect
        if value.blank?
          related_model = nil
        else
          related_class = model.class.reflections[name.to_s.downcase].class_name
          related_model = related_class.safe_constantize.find value
        end

        model.public_send("#{key}=", related_model)

        model
      end
    end
  end
end
