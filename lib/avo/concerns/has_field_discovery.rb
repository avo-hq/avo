# frozen_string_literal: true

# TODO: Refactor this concern to be more readable and maintainable
# rubocop:disable Metrics/ModuleLength
module Avo
  module Concerns
    # This concern facilitates field discovery for models in Avo,
    # mapping database columns and associations to Avo fields.
    # It supports:
    #  - Automatic detection of fields based on column names, types, and associations.
    #  - Customization via `only`, `except`, and global configuration overrides.
    #  - Handling of special associations like rich text, attachments, and tags.
    module HasFieldDiscovery
      extend ActiveSupport::Concern

      COLUMN_NAMES_TO_IGNORE = %i[
        encrypted_password reset_password_token reset_password_sent_at remember_created_at password_digest
      ].freeze

      class_methods do
        def column_names_mapping
          @column_names_mapping ||= Avo::Mappings::NAMES_MAPPING.dup
            .merge(Avo.configuration.column_names_mapping || {})
        end

        def column_types_mapping
          @column_types_mapping ||= Avo::Mappings::FIELDS_MAPPING.dup
            .merge(Avo.configuration.column_types_mapping || {})
        end
      end

      # Returns database columns for the model, excluding ignored columns
      def model_db_columns
        @model_db_columns ||= safe_model_class.columns_hash.symbolize_keys.except(*COLUMN_NAMES_TO_IGNORE)
      end

      # Discovers and configures database columns as fields
      def discover_columns(only: nil, except: nil, **field_options)
        setup_discovery_options(only, except, field_options)
        return unless safe_model_class.respond_to?(:columns_hash)

        discoverable_columns.each do |column_name, column|
          process_column(column_name, column)
        end

        discover_tags
        discover_rich_texts
      end

      # Discovers and configures associations as fields
      def discover_associations(only: nil, except: nil, **field_options)
        setup_discovery_options(only, except, field_options)
        return unless safe_model_class.respond_to?(:reflections)

        discover_attachments
        discover_basic_associations
      end

      private

      def setup_discovery_options(only, except, field_options)
        @only = only
        @except = except
        @field_options = field_options
      end

      def discoverable_columns
        model_db_columns.reject do |column_name, _|
          skip_column?(column_name)
        end
      end

      def skip_column?(column_name)
        !column_in_scope?(column_name) ||
          reflections.key?(column_name) ||
          rich_text_column?(column_name)
      end

      def rich_text_column?(column_name)
        rich_texts.key?(:"rich_text_#{column_name}")
      end

      def process_column(column_name, column)
        field_config = determine_field_config(column_name, column)
        return unless field_config

        create_field(column_name, field_config)
      end

      def create_field(column_name, field_config)
        field_options = {as: field_config.dup.delete(:field).to_sym}.merge(field_config)
        field(column_name, **field_options.symbolize_keys, **@field_options.symbolize_keys)
      end

      def create_attachment_field(association_name, reflection)
        field_name = association_name&.to_s&.delete_suffix("_attachment")&.to_sym || association_name
        field_type = determine_attachment_field_type(reflection)
        field(field_name, as: field_type, **@field_options)
      end

      def determine_attachment_field_type(reflection)
        (
          reflection.is_a?(ActiveRecord::Reflection::HasOneReflection) ||
          reflection.is_a?(ActiveStorage::Reflection::HasOneAttachedReflection)
        ) ? :file : :files
      end

      def create_association_field(association_name, reflection)
        options = base_association_options(reflection)
        options.merge!(polymorphic_options(reflection)) if reflection.options[:polymorphic]

        field(association_name, **options, **@field_options)
      end

      def base_association_options(reflection)
        {
          as: reflection.macro,
          searchable: true,
          sortable: true
        }
      end

      # Fetches the model class, falling back to the items_holder parent record in certain instances
      # (e.g. in the context of the sidebar)
      def safe_model_class
        respond_to?(:model_class) ? model_class : @items_holder.parent.model_class
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
        nil
      end

      def model_enums
        @model_enums ||= if safe_model_class.respond_to?(:defined_enums)
          safe_model_class.defined_enums.transform_values do |enum|
            {
              field: :select,
              enum:
            }
          end
        else
          {}
        end.with_indifferent_access
      end

      # Determines if a column is included in the discovery scope.
      # A column is in scope if it's included in `only` and not in `except`.
      def column_in_scope?(column_name)
        (!@only || @only.include?(column_name)) && (!@except || !@except.include?(column_name))
      end

      def determine_field_config(attribute, column)
        model_enums[attribute.to_s] ||
          self.class.column_names_mapping[attribute] ||
          self.class.column_types_mapping[column.type]
      end

      def discover_by_type(associations, as_type)
        associations.each_key do |association_name|
          next unless column_in_scope?(association_name)

          field association_name, as: as_type, **@field_options.merge(name: yield(association_name))
        end
      end

      def discover_rich_texts
        rich_texts.each_key do |association_name|
          next unless column_in_scope?(association_name)

          field_name = association_name&.to_s&.delete_prefix("rich_text_")&.to_sym || association_name
          field field_name, as: :trix, **@field_options
        end
      end

      def discover_tags
        tags.each_key do |association_name|
          next unless column_in_scope?(association_name)

          field(
            tag_field_name(association_name), as: :tags,
            acts_as_taggable_on: tag_field_name(association_name),
            **@field_options
          )
        end
      end

      def tag_field_name(association_name)
        association_name&.to_s&.delete_suffix("_taggings")&.pluralize&.to_sym || association_name
      end

      def discover_attachments
        attachment_associations.each do |association_name, reflection|
          next unless column_in_scope?(association_name)

          create_attachment_field(association_name, reflection)
        end
      end

      def discover_basic_associations
        associations.each do |association_name, reflection|
          next unless column_in_scope?(association_name)

          create_association_field(association_name, reflection)
        end
      end

      def polymorphic_options(reflection)
        {polymorphic_as: reflection.name, types: detect_polymorphic_types(reflection)}
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
        @associations ||= reflections.reject do |key|
          attachment_associations.key?(key) || tags.key?(key) || rich_texts.key?(key)
        end
      end

      def ignore_reflection?(name)
        %w[blob blobs tags].include?(name.split("_").pop) || name.to_sym == :taggings
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
