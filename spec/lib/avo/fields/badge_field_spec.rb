require "rails_helper"

RSpec.describe Avo::Fields::BadgeField, type: :model do
  let(:field) { described_class.new(:status) }

  # Helper method to set field value
  def stub_field_value(value)
    allow(field).to receive(:value).and_return(value)
  end

  # Helper method to set options
  def set_options(options_hash)
    field.instance_variable_set(:@options, options_hash)
  end

  describe "#badge_color_for_value" do
    context "when value is blank" do
      it "returns neutral" do
        stub_field_value(nil)
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end

    context "when value matches options" do
      before do
        set_options({
          success: ["Done", :Complete],
          danger: :Cancelled,
          warning: ["On hold"],
          info: [:idea, "Idea"]
        })
      end

      [
        ["Done", "success"],
        [:Complete, "success"],
        ["Cancelled", "danger"],
        ["On hold", "warning"],
        ["Idea", "info"]
      ].each do |value, expected_color|
        it "returns #{expected_color} for '#{value}'" do
          stub_field_value(value)
          expect(field.badge_color_for_value).to eq(expected_color)
        end
      end
    end

    context "when value does not match options" do
      before do
        set_options({
          success: ["Done"],
          danger: ["Cancelled"]
        })
      end

      it "returns neutral for unknown value" do
        stub_field_value("unknown")
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end

    context "when options are empty" do
      it "returns neutral for any value" do
        set_options({})
        stub_field_value("any_value")
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end
  end

  describe "#color" do
    it "delegates to badge_color_for_value" do
      set_options({success: ["Done"]})
      stub_field_value("Done")
      expect(field.color).to eq(field.badge_color_for_value)
    end
  end

  describe "#style" do
    def stub_execute_context(input, output)
      allow(field).to receive(:execute_context).with(input).and_return(output)
    end

    context "when explicit style is provided" do
      it "returns the explicit style" do
        field.instance_variable_set(:@style, "solid")
        stub_execute_context("solid", "solid")
        expect(field.style).to eq("solid")
      end
    end

    context "when style is provided as a proc" do
      it "executes the proc and returns the result" do
        field.instance_variable_set(:@style, -> { "solid" })
        stub_execute_context(anything, "solid")
        expect(field.style).to eq("solid")
      end
    end

    context "when no explicit style is provided" do
      it "defaults to subtle" do
        field.instance_variable_set(:@style, nil)
        stub_execute_context(nil, nil)
        expect(field.style).to eq("subtle")
      end
    end
  end

  describe "#icon" do
    def stub_execute_context(input, output)
      allow(field).to receive(:execute_context).with(input).and_return(output)
    end

    [
      ["string icon", "tabler/outline/check", "tabler/outline/check"],
      ["proc icon", -> { "tabler/outline/alert" }, "tabler/outline/alert"]
    ].each do |description, icon_value, expected_result|
      context "when icon is provided as #{description}" do
        it "executes context and returns the icon" do
          field.instance_variable_set(:@icon, icon_value)
          stub_execute_context(icon_value.is_a?(Proc) ? anything : icon_value, expected_result)
          expect(field.icon).to eq(expected_result)
        end
      end
    end

    context "when no icon is provided" do
      it "returns nil" do
        field.instance_variable_set(:@icon, nil)
        stub_execute_context(nil, nil)
        expect(field.icon).to be_nil
      end
    end
  end

  describe "#options_for_filter" do
    [
      [
        "arrays",
        {success: ["Done", :Complete], danger: ["Cancelled"], warning: ["On hold", "Pending"], info: ["Discovery", "Idea"]},
        ["Done", :Complete, "Cancelled", "On hold", "Pending", "Discovery", "Idea"]
      ],
      [
        "single values",
        {success: :Done, danger: "Cancelled", info: "Discovery"},
        [:Done, "Cancelled", "Discovery"]
      ],
      [
        "empty hash",
        {},
        []
      ]
    ].each do |description, options, expected_result|
      context "when options contain #{description}" do
        it "returns the correct flattened values" do
          set_options(options)
          expect(field.options_for_filter).to match_array(expected_result)
        end
      end
    end
  end
end
