module Avo
  module Concerns
    # This concern facilitates field discovery for models in Avo, mapping database columns and associations to Avo fields.
    # It supports:
    #  - Automatic detection of fields based on column names, types, and associations.
    #  - Customization via `only`, `except`, and global configuration overrides.
    #  - Handling of special associations like rich text, attachments, and tags.
    module HasFieldDiscovery
      extend ActiveSupport::Concern

      DEFAULT_COLUMN_NAMES_MAPPING = {
        id: { field: "id" },
        description: { field: "textarea" },
        gravatar: { field: "gravatar" },
        email: { field: "text" },
        password: { field: "password" },
        password_confirmation: { field: "password" },
        created_at: { field: "date_time" },
        updated_at: { field: "date_time" },
        stage: { field: "select" },
        budget: { field: "currency" },
        money: { field: "currency" },
        country: { field: "country" },
      }.freeze

      DEFAULT_COLUMN_TYPES_MAPPING = {
        primary_key: { field: "id" },
        string: { field: "text" },
        text: { field: "textarea" },
        integer: { field: "number" },
        float: { field: "number" },
        decimal: { field: "number" },
        datetime: { field: "date_time" },
        timestamp: { field: "date_time" },
        time: { field: "date_time" },
        date: { field: "date" },
        binary: { field: "number" },
        boolean: { field: "boolean" },
        references: { field: "belongs_to" },
        json: { field: "code" },
      }.freeze

      COLUMN_NAMES_TO_IGNORE = %i[
        encrypted_password reset_password_token reset_password_sent_at remember_created_at password_digest
      ].freeze

      class_methods do
        def column_names_mapping
          @column_names_mapping ||= DEFAULT_COLUMN_NAMES_MAPPING.dup
                                    .except(*COLUMN_NAMES_TO_IGNORE)
                                    .merge(Avo.configuration.column_names_mapping || {})
        end

        def column_types_mapping
          @column_types_mapping ||= DEFAULT_COLUMN_TYPES_MAPPING.dup
                                    .merge(Avo.configuration.column_types_mapping || {})
        end
      end

      # Returns database columns for the model, excluding ignored columns
      def model_db_columns
        @model_db_columns ||= safe_model_class.columns_hash.symbolize_keys.except(*COLUMN_NAMES_TO_IGNORE)
      end

      # Discovers and configures database columns as fields
      def discover_columns(only: nil, except: nil, **field_options)
        @only, @except, @field_options = only, except, field_options
        return unless safe_model_class.respond_to?(:columns_hash)

        model_db_columns.each do |column_name, column|
          next unless column_in_scope?(column_name)
          next if reflections.key?(column_name) || rich_texts.key?("rich_text_#{column_name}")

          field_config = determine_field_config(column_name, column)
          next unless field_config

          field_options = build_field_options(field_config, column)
          field column_name, **field_options, **@field_options
        end
      end

      # Discovers and configures associations as fields
      def discover_associations(only: nil, except: nil, **field_options)
        @only, @except, @field_options = only, except, field_options
        return unless safe_model_class.respond_to?(:reflections)

        discover_by_type(tags, :tags) { |name| name.split("_").pop.join("_").pluralize }
        discover_by_type(rich_texts, :trix) { |name| name.delete_prefix("rich_text_") }
        discover_attachments
        discover_basic_associations
      end

      private

      # Fetches the model class, falling back to the items_holder parent record in certain instances (e.g. in the context of the sidebar)
      def safe_model_class
        respond_to?(:model_class) ? model_class : @items_holder.parent.record.class
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
        nil
      end

      # Determines if a column is included in the discovery scope.
      # A column is in scope if it's included in `only` and not in `except`.
      def column_in_scope?(column_name)
        (!@only || @only.include?(column_name)) && (!@except || !@except.include?(column_name))
      end

      def determine_field_config(attribute, column)
        if safe_model_class.respond_to?(:defined_enums) && safe_model_class.defined_enums[attribute.to_s]
          return { field: "select", enum: "::#{safe_model_class.name}.#{attribute.to_s.pluralize}" }
        end

        self.class.column_names_mapping[attribute] || self.class.column_types_mapping[column.type]
      end

      def build_field_options(field_config, column)
        { as: field_config[:field].to_sym, required: !column.null }.merge(field_config.except(:field))
      end

      def discover_by_type(associations, as_type)
        associations.each_key do |association_name|
          next unless column_in_scope?(association_name)

          field association_name, as: as_type, **@field_options.merge(yield(association_name))
        end
      end

      def discover_attachments
        attachment_associations.each do |association_name, reflection|
          next unless column_in_scope?(association_name)

          field_type = reflection.options[:as] == :has_one_attached ? :file : :files
          field association_name, as: field_type, **@field_options
        end
      end

      def discover_basic_associations
        associations.each do |association_name, reflection|
          next unless column_in_scope?(association_name)

          options = { as: reflection.macro, searchable: true, sortable: true }
          options.merge!(polymorphic_options(reflection)) if reflection.options[:polymorphic]

          field association_name, **options, **@field_options
        end
      end

      def polymorphic_options(reflection)
        { polymorphic_as: reflection.name, types: detect_polymorphic_types(reflection) }
      end

      def detect_polymorphic_types(reflection)
        ApplicationRecord.descendants.select { |klass| klass.reflections[reflection.plural_name] }
      end

      def reflections
        @reflections ||= safe_model_class.reflections.symbolize_keys.reject do |name, _|
          ignore_reflection?(name.to_s)
        end
      end

      def attachment_associations
        @attachment_associations ||= reflections.select { |_, r| r.options[:class_name] == "ActiveStorage::Attachment" }
      end

      def rich_texts
        @rich_texts ||= reflections.select { |_, r| r.options[:class_name] == "ActionText::RichText" }
      end

      def tags
        @tags ||= reflections.select { |_, r| r.options[:as] == :taggable }
      end

      def associations
        @associations ||= reflections.reject { |key| attachment_associations.key?(key) || tags.key?(key) || rich_texts.key?(key) }
      end

      def ignore_reflection?(name)
        %w[blob blobs tags].include?(name.split("_").pop) || name.to_sym == :taggings
      end
    end
  end
end
