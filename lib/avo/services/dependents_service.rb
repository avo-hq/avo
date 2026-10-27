module Avo
  module Services
    class DependentsService
      # :nullify and :restrict_with_* leave the records in place, so they are not worth a warning.
      REMOVING = [:destroy, :destroy_async, :delete, :delete_all].freeze
      # :delete and :delete_all skip callbacks, so the records they remove take nothing else down with them.
      CASCADING = [:destroy, :destroy_async].freeze
      # Guards against self-referencing trees (a category destroying its children) that are deeper than any real use.
      MAX_DEPTH = 10

      # Lets the delete button skip the request for models nothing depends on, without running a query.
      def self.applies_to?(record)
        record.is_a?(ActiveRecord::Base) && record.persisted? && removing_reflections(record.class).any?
      end

      def self.removing_reflections(model)
        model.reflect_on_all_associations.select do |reflection|
          REMOVING.include?(reflection.options[:dependent]) && !reflection.through_reflection?
        end
      end

      def initialize(record)
        @record = record
        model = record.class
        @counted = {model.base_class => [model.where(model.primary_key => record.id)]}
      end

      # => "3 books, 12 chapters and 1 review"
      def summary
        counts = {}

        self.class.removing_reflections(@record.class).each do |reflection|
          collect(reflection, @record.association(reflection.name).scope, counts, depth: 1)
        end

        counts.map { |reflection, count| "#{count} #{label(reflection, count)}" }.to_sentence.presence
      end

      private

      def collect(reflection, scope, counts, depth:)
        scope = without_counted(scope)
        count = scope.count
        return if count.zero?

        (@counted[scope.klass.base_class] ||= []) << scope
        counts[reflection] = counts.fetch(reflection, 0) + count
        return unless CASCADING.include?(reflection.options[:dependent]) && depth < MAX_DEPTH

        self.class.removing_reflections(scope.klass).each do |child|
          children = children_of(child, scope)
          collect(child, children, counts, depth: depth + 1) if children
        end
      end

      # Two associations can reach the same rows (acts-as-taggable's taggings and tag_taggings), and a destroy
      # removes them once. Excluding counted rows also ends cycles, such as a child that destroys its parent.
      def without_counted(scope)
        primary_key = scope.klass.primary_key
        return scope if primary_key.is_a?(Array)

        @counted.fetch(scope.klass.base_class, []).reduce(scope) do |remaining, counted|
          remaining.where.not(primary_key => counted.select(primary_key))
        end
      end

      # Builds the association for a whole level of parents as one query, so nothing below the record gets loaded.
      # Returns nil for the cases a query cannot express: polymorphic targets, composite keys and owner-dependent scopes.
      def children_of(reflection, parents)
        return if reflection.polymorphic? || reflection.scope&.arity&.positive?

        primary_key, foreign_key = reflection.join_primary_key, reflection.join_foreign_key
        return if primary_key.is_a?(Array) || foreign_key.is_a?(Array)

        children = reflection.klass.where(primary_key => parents.select(foreign_key))
        children = children.where(reflection.type => reflection.active_record.polymorphic_name) if reflection.type
        reflection.scope ? reflection.scope_for(children) : children
      end

      def label(reflection, count)
        model = reflection.active_record
        key = "#{model.i18n_scope}.attributes.#{model.model_name.i18n_key}.#{reflection.name}"
        return I18n.t(key, count: count) if I18n.exists?(key)

        reflection.name.to_s.humanize(capitalize: false).singularize.pluralize(count)
      end
    end
  end
end
