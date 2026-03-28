# TODO: json API, forms, http resource, reactive fields, nested resources, MCP, kanban

class Avo::Services::TelemetryService
  class << self
    def telemetry_info
      {
        avo_metadata: avo_metadata,
        avo_version: Avo::VERSION,
        rails_version: Rails::VERSION::STRING,
        ruby_version: RUBY_VERSION,
        environment: Rails.env.to_s,
        app_name: app_name,
      }
    end

    def app_name
      Rails.application.class.to_s.split("::").first
    rescue
      nil
    end

    def avo_metadata
      resource_classes = Avo.resource_manager.all
      dashboards = defined?(Avo::Dashboards) ? Avo::Dashboards.dashboard_manager.all : []
      resources_with_ordering = 0
      resources_with_custom_controls = {
        show_controls: 0,
        edit_controls: 0,
        index_controls: 0,
        row_controls: 0,
      }
      total_cards = 0
      total_dividers = 0
      total_dynamic_filters = 0
      resources_with_dynamic_filters = 0
      resources_with_collaboration = 0
      resources_with_collaboration_watchers = 0
      resources_with_collaboration_reactions = 0
      resources_with_audit_logging = 0

      resources = resource_classes.map do |resource_class|
        resource = resource_class.new view: :index
        resource.detect_fields
        resources_with_ordering += 1 if resource_class.ordering.present?

        # Track custom controls
        resources_with_custom_controls[:show_controls] += 1 if resource_class.show_controls.present?
        resources_with_custom_controls[:edit_controls] += 1 if resource_class.edit_controls.present?
        resources_with_custom_controls[:index_controls] += 1 if resource_class.index_controls.present?
        resources_with_custom_controls[:row_controls] += 1 if resource_class.row_controls.present?

        # Track dynamic filters if available
        begin
          dynamic_filters = resource.custom_dynamic_filters
          if dynamic_filters.present?
            resources_with_dynamic_filters += 1
            total_dynamic_filters += dynamic_filters.count
          end
        rescue
          # Skip if dynamic filters not available
        end

        # Track collaboration if available
        begin
          if resource_class.collaboration.present?
            resources_with_collaboration += 1
            watchers = resource_class.collaboration.dig(:watchers)
            resources_with_collaboration_watchers += 1 if watchers.present?
            reactions = resource_class.collaboration.dig(:reactions)
            resources_with_collaboration_reactions += 1 if reactions.present?
          end
        rescue
          # Skip if collaboration not available
        end

        # Track audit_logging if available
        begin
          resources_with_audit_logging += 1 if resource_class.audit_logging.present?
        rescue
          # Skip if audit_logging not available
        end

        resource
      end

      # Count cards and dividers in resources
      resources.each do |resource|
        resource.detect_cards
        cards = resource.send(:cards_holder)
        cards.each do |item|
          if item.is_a?(Avo::Cards::BaseDivider)
            total_dividers += 1
          else
            total_cards += 1
          end
        end
      rescue
        # Skip if resource doesn't have cards support
      end

      # Count cards and dividers in dashboards
      dashboards.each do |dashboard|
        dashboard.detect_cards
        cards = dashboard.send(:cards_holder)
        cards.each do |item|
          if item.is_a?(Avo::Cards::BaseDivider)
            total_dividers += 1
          else
            total_cards += 1
          end
        end
      rescue
        # Skip if dashboard doesn't have cards or if there's an error
      end
      field_definitions = resources.map(&:get_field_definitions)
      # flat_fields = field_definitions.dup.flatten
      # field_types = flat_fields.map(&:type).uniq
      fields_count = field_definitions.map(&:count).sum
      fields_per_resource = sprintf("%0.01f", fields_count / (resources.count + 0.0)).to_f

      field_types_count = {}
      custom_fields_count = 0
      file_fields_with_direct_upload = 0
      files_fields_with_direct_upload = 0
      field_definitions.each do |fields|
        fields.each do |field|
          field_types_count[field.type] ||= 0
          field_types_count[field.type] += 1

          custom_fields_count += 1 if field.custom?

          # Track direct_upload usage
          file_fields_with_direct_upload += 1 if field.type == :file && field.direct_upload
          files_fields_with_direct_upload += 1 if field.type == :files && field.direct_upload
        end
      end

      fields_hash = {
        count: fields_count,
        per_resource: fields_per_resource,
        custom_count: custom_fields_count,
        types_count: field_types_count,
        types: field_types_count.keys,
      }

      # Only include direct_upload if it's being used
      if file_fields_with_direct_upload > 0 || files_fields_with_direct_upload > 0
        fields_hash[:direct_upload] = {
          file_fields_count: file_fields_with_direct_upload,
          files_fields_count: files_fields_with_direct_upload,
        }
      end

      {
        resources: {
          count: resources.count,
          with_ordering: resources_with_ordering,
          custom_controls: resources_with_custom_controls,
          collaboration: {
            enabled: resources_with_collaboration,
            with_watchers: resources_with_collaboration_watchers,
            with_reactions: resources_with_collaboration_reactions,
          },
          audit_logging_enabled: resources_with_audit_logging,
        },
        dashboards: {
          count: dashboards.count,
          cards_count: total_cards,
          dividers_count: total_dividers,
          cards_per_dashboard: (dashboards.count > 0) ? sprintf("%0.01f", total_cards / dashboards.count.to_f).to_f : 0.0,
        },
        fields: fields_hash,
        actions: {
          **other_metadata(:actions, resources:),
          **action_options_metadata(resources:),
          **action_fields_metadata(resources:),
        },
        filters: {
          **other_metadata(:filters, resources:),
        },
        dynamic_filters: {
          count: total_dynamic_filters,
          resources_with_count: resources_with_dynamic_filters,
        },
        scopes: {
          **other_metadata(:scopes, resources:),
        },
        configuration: {
          main_menu_present: Avo.configuration.main_menu.present?,
          profile_menu_present: Avo.configuration.profile_menu.present?,
          cache_store: Avo.cache_store&.class&.to_s,
          cache_operational: cache_operational?,
        },
        authorization: authorization_metadata,
        **config_metadata
      }

      # rescue => error
      #   {
      #     error: error.message
      #   }
    end

    def detect_metadata(name, &block)
      instance_eval(&block)
    rescue => error
      {
        "#{name}_error": error.message
      }
    end

    def cache_operational?
      Avo.cache_store.write("avo-test-cache", "test_value")
      operational = Avo.cache_store.read("avo-test-cache") == "test_value"
      Avo.cache_store.delete("avo-test-cache")
      operational
    rescue => error
      "error: #{error.message}"
    end

    def other_metadata(type = :actions, resources:)
      types = resources.map(&:"get_#{type}")
      type_count = types.flatten.uniq.count
      type_per_resource = sprintf("%0.01f", types.map(&:count).sum / (resources.count + 0.0))

      {
        "#{type}_count": type_count,
        "#{type}_per_resource": type_per_resource
      }
    end

    def distinct_action_classes(resources:)
      resources.flat_map { |resource| resource.get_actions.filter_map { |e| e[:class] unless e[:class] == Avo::Divider } }.uniq
    end

    # Class-level options (read before any action #initialize, which may fill `message` via ||=).
    # Counts unique action classes where each attribute differs from Avo::BaseAction defaults.
    def action_options_metadata(resources:)
      base = Avo::BaseAction
      counts = {
        actions_with_name_count: 0,
        actions_with_description_count: 0,
        actions_with_message_count: 0,
        actions_with_visible_count: 0,
        actions_with_confirmation_count: 0,
        actions_with_standalone_count: 0,
        actions_with_authorize_count: 0,
      }

      distinct_action_classes(resources:).each do |action_class|
        counts[:actions_with_name_count] += 1 if !action_class.name.nil?
        counts[:actions_with_description_count] += 1 if !action_class.description.nil?
        counts[:actions_with_message_count] += 1 if !action_class.message.nil?
        counts[:actions_with_visible_count] += 1 if action_class.visible != base.visible
        counts[:actions_with_confirmation_count] += 1 if action_class.confirmation != base.confirmation
        counts[:actions_with_standalone_count] += 1 if action_class.standalone != base.standalone
        counts[:actions_with_authorize_count] += 1 if action_class.authorize != base.authorize
      end

      counts
    end

    # Instantiates each action like ActionsController does, runs #fields, and reads form fields via #only_fields.
    # Skips Avo::Divider entries. Counts unique action classes: any registration that yields fields marks the class as "with".
    def action_fields_metadata(resources:)
      action_fields_count = 0
      action_field_types_count = Hash.new(0)
      form_fields_by_action_class = Hash.new { |h, k| h[k] = {saw_fields: false} }

      resources.each do |resource|
        resource.get_actions.each do |entry|
          next if entry[:class] == Avo::Divider

          action_class = entry[:class]
          class_key = action_class.to_s
          bucket = form_fields_by_action_class[class_key]

          begin
            action = action_class.new(
              record: resource.record,
              resource: resource,
              user: resource.user,
              view: :new,
              arguments: entry[:arguments] || {},
              query: nil,
              index_query: nil
            )
            action.fields
            fields = action.only_fields

            action_fields_count += fields.size
            fields.each do |field|
              action_field_types_count[field.type] += 1
            end

            bucket[:saw_fields] = bucket[:saw_fields] || fields.any?
          rescue
            # Leave saw_fields false unless another resource runs this action successfully with fields.
          end
        end
      end

      actions_with_form_fields_count = form_fields_by_action_class.count { |_, v| v[:saw_fields] }
      actions_without_form_fields_count = form_fields_by_action_class.count { |_, v| !v[:saw_fields] }

      {
        actions_with_form_fields_count: actions_with_form_fields_count,
        actions_without_form_fields_count: actions_without_form_fields_count,
        action_fields_count: action_fields_count,
        action_field_types_count: action_field_types_count,
        action_field_types: action_field_types_count.keys,
      }
    end

    def authorization_metadata
      client = Avo.configuration.authorization_client

      # Check if authorization is actually enabled (not just configured)
      authorization_enabled = if defined?(Avo::Pro)
        # In Pro, check if license has authorization
        !Avo::Current.license.lacks_with_trial(:authorization) && client.present?
      else
        # In core, authorization is always a no-op
        false
      end

      client_name = case client
      when nil
        nil
      when :pundit
        :pundit
      when String
        client.to_sym
      else
        client.class.to_s.to_sym
      end

      pundit_policies_count = count_pundit_policies

      {
        authorization_enabled:,
        authorization_client: client_name,
        explicit_authorization: Avo.configuration.explicit_authorization,
        pundit_policies_count:,
      }
    rescue => error
      {
        authorization_metadata_error: error.message
      }
    end

    def count_pundit_policies
      return 0 unless defined?(Pundit)

      # Count policy classes in the app/policies directory
      policies_path = Rails.root.join("app", "policies")
      return 0 unless policies_path.exist?

      Dir.glob(policies_path.join("**/*_policy.rb")).count
    rescue
      0
    end

    def config_metadata
      {
        config: {
          root_path: Avo.configuration.root_path,
          app_name: Avo.configuration.app_name
        }
      }
    end
  end
end
