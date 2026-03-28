# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::Services::TelemetryService do
  describe ".avo_metadata" do
    before do
      Avo::Current.resource_manager = Avo::Resources::ResourceManager.build
    end

    let(:unique_action_class_keys) do
      Avo.resource_manager.all.flat_map do |resource_class|
        resource_class.new(view: :index).get_actions.filter_map do |entry|
          next if entry[:class] == Avo::Divider

          entry[:class].to_s
        end
      end.uniq
    end

    it "has organized structure with resources, dashboards, fields, actions, filters, dynamic_filters, scopes, configuration, authorization groups" do
      meta = described_class.avo_metadata

      expect(meta).to have_key(:resources)
      expect(meta).to have_key(:dashboards)
      expect(meta).to have_key(:fields)
      expect(meta).to have_key(:actions)
      expect(meta).to have_key(:filters)
      expect(meta).to have_key(:dynamic_filters)
      expect(meta).to have_key(:scopes)
      expect(meta).to have_key(:configuration)
      expect(meta).to have_key(:authorization)
    end

    it "reports resources metadata" do
      meta = described_class.avo_metadata

      expect(meta[:resources][:count]).to be_a(Integer)
      expect(meta[:resources][:count]).to be_positive
      expect(meta[:resources][:with_ordering]).to be_a(Integer)
      expect(meta[:resources][:with_ordering]).to be >= 0
      expect(meta[:resources][:custom_controls]).to be_a(Hash)
      expect(meta[:resources][:custom_controls][:show_controls]).to be_a(Integer)
      expect(meta[:resources][:custom_controls][:edit_controls]).to be_a(Integer)
      expect(meta[:resources][:custom_controls][:index_controls]).to be_a(Integer)
      expect(meta[:resources][:custom_controls][:row_controls]).to be_a(Integer)
      expect(meta[:resources][:collaboration]).to be_a(Hash)
      expect(meta[:resources][:collaboration][:enabled]).to be_a(Integer)
      expect(meta[:resources][:collaboration][:enabled]).to be >= 0
      expect(meta[:resources][:collaboration][:with_watchers]).to be_a(Integer)
      expect(meta[:resources][:collaboration][:with_watchers]).to be >= 0
      expect(meta[:resources][:collaboration][:with_watchers]).to be <= meta[:resources][:collaboration][:enabled]
      expect(meta[:resources][:collaboration][:with_reactions]).to be_a(Integer)
      expect(meta[:resources][:collaboration][:with_reactions]).to be >= 0
      expect(meta[:resources][:collaboration][:with_reactions]).to be <= meta[:resources][:collaboration][:enabled]
      expect(meta[:resources][:audit_logging_enabled]).to be_a(Integer)
      expect(meta[:resources][:audit_logging_enabled]).to be >= 0
    end

    it "reports dashboards metadata including cards" do
      meta = described_class.avo_metadata

      expect(meta[:dashboards][:count]).to be_a(Integer)
      expect(meta[:dashboards][:cards_count]).to be_a(Integer)
      expect(meta[:dashboards][:dividers_count]).to be_a(Integer)
      expect(meta[:dashboards][:cards_per_dashboard]).to be_a(Float)
    end

    it "reports fields metadata" do
      meta = described_class.avo_metadata
      fields = meta[:fields]

      expect(fields[:count]).to be_a(Integer)
      expect(fields[:per_resource]).to be_a(Float)
      expect(fields[:custom_count]).to be_a(Integer)
      expect(fields[:types_count]).to be_a(Hash)
      expect(fields[:types]).to be_an(Array)
    end

    it "reports direct_upload only if used" do
      meta = described_class.avo_metadata
      fields = meta[:fields]

      if fields[:direct_upload].present?
        expect(fields[:direct_upload][:file_fields_count]).to be_a(Integer)
        expect(fields[:direct_upload][:files_fields_count]).to be_a(Integer)
        expect(fields[:direct_upload][:file_fields_count] + fields[:direct_upload][:files_fields_count]).to be_positive
      end
    end

    it "reports how many unique action classes have form fields vs not" do
      meta = described_class.avo_metadata
      actions = meta[:actions]

      expect(actions[:action_fields_count]).to be_a(Integer)
      expect(actions[:actions_with_form_fields_count]).to be_a(Integer)
      expect(actions[:actions_without_form_fields_count]).to be_a(Integer)

      expect(actions[:actions_with_form_fields_count] + actions[:actions_without_form_fields_count]).to eq(
        unique_action_class_keys.size
      )
      expect(actions[:actions_with_form_fields_count]).to be_positive
    end

    it "reports counts of action classes customizing name, description, message, visible, confirmation, standalone, authorize" do
      meta = described_class.avo_metadata
      actions = meta[:actions]
      n = unique_action_class_keys.size

      %i[
        actions_with_name_count
        actions_with_description_count
        actions_with_message_count
        actions_with_visible_count
        actions_with_confirmation_count
        actions_with_standalone_count
        actions_with_authorize_count
      ].each do |key|
        expect(actions[key]).to be_a(Integer)
        expect(actions[key]).to be <= n
      end

      expect(actions[:actions_with_name_count]).to be_positive
    end

    it "reports filters metadata" do
      meta = described_class.avo_metadata
      filters = meta[:filters]

      expect(filters[:filters_count]).to be_a(Integer)
      expect(filters[:filters_per_resource]).to be_a(String)
    end

    it "reports dynamic filters metadata" do
      meta = described_class.avo_metadata
      dynamic_filters = meta[:dynamic_filters]

      expect(dynamic_filters[:count]).to be_a(Integer)
      expect(dynamic_filters[:resources_with_count]).to be_a(Integer)
    end

    it "reports scopes metadata" do
      meta = described_class.avo_metadata
      scopes = meta[:scopes]

      expect(scopes[:scopes_count]).to be_a(Integer)
      expect(scopes[:scopes_per_resource]).to be_a(String)
    end

    it "reports configuration metadata" do
      meta = described_class.avo_metadata
      config = meta[:configuration]

      expect(config[:main_menu_present]).to be_in([true, false])
      expect(config[:profile_menu_present]).to be_in([true, false])
      expect(config[:cache_store]).to be_nil.or be_a(String)
      expect(config[:cache_operational]).to be_in([true, false])
    end

    it "reports authorization configuration and usage" do
      meta = described_class.avo_metadata
      auth = meta[:authorization]

      expect(auth[:authorization_enabled]).to be_in([true, false])
      expect(auth[:authorization_client]).to be_nil.or be_a(Symbol)
      expect(auth[:explicit_authorization]).to be_in([true, false])
      expect(auth[:pundit_policies_count]).to be_a(Integer)
    end
  end
end
