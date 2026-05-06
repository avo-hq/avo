require "rails_helper"

# Component-layer integration coverage. The full merge contract is exercised
# in `spec/lib/avo/table_row_options_spec.rb`; this file covers the parts that
# only the component owns: `view` derivation and the wiring of the merger
# call.
RSpec.describe Avo::Index::TableRowComponent, type: :component do
  let(:user) { User.create!(first_name: "Adrian", last_name: "Marin", email: "adrian@example.com", password: "secret123") }
  let(:resource) { Avo::Resources::User.new(record: user, view: Avo::ViewInquirer.new("index")) }

  def build_component(reflection: nil, parent_record: nil, parent_resource: nil)
    component = described_class.new(
      resource: resource,
      reflection: reflection,
      parent_record: parent_record,
      parent_resource: parent_resource,
      actions: [],
      fields: [],
      header_fields: [],
      index: 0,
      row_selector_checked: false
    )
    # `click_row_to_view_record` calls `helpers` (only available inside render).
    # Disable it for component-method-level tests that don't go through render.
    allow(component).to receive(:click_row_to_view_record).and_return(false)
    component
  end

  describe "#view" do
    it "returns :index when there is no reflection" do
      component = build_component
      expect(component.view).to eq(:index)
    end

    it "returns :has_many when a reflection is present" do
      reflection = double("Reflection", present?: true)
      component = build_component(reflection: reflection)
      expect(component.view).to eq(:has_many)
    end
  end

  describe "#merged_tr_attributes" do
    it "delegates to Avo::TableRowOptions.merge with the right kwargs" do
      component = build_component
      expect(Avo::TableRowOptions).to receive(:merge).with(
        avo_attributes: hash_including(:id, :class, :data),
        user_options: anything,
        record: user,
        resource: resource,
        view: :index
      ).and_call_original

      component.merged_tr_attributes
    end

    it "passes the resource's table_view[:row_options] as user_options" do
      Avo::Resources::User.table_view = {row_options: {class: "highlight"}}
      component = build_component

      expect(Avo::TableRowOptions).to receive(:merge).with(
        hash_including(user_options: {class: "highlight"})
      ).and_call_original

      component.merged_tr_attributes
    ensure
      Avo::Resources::User.table_view = nil
    end

    it "passes nil user_options when the resource has no table_view" do
      Avo::Resources::User.table_view = nil
      component = build_component

      expect(Avo::TableRowOptions).to receive(:merge).with(
        hash_including(user_options: nil)
      ).and_call_original

      component.merged_tr_attributes
    end
  end
end
