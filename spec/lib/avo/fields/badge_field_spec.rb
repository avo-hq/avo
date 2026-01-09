require "rails_helper"

RSpec.describe Avo::Fields::BadgeField, type: :model do
  let(:field) { described_class.new(:status) }

  describe "#badge_color_for_value" do
    context "when value is blank" do
      before do
        allow(field).to receive(:value).and_return(nil)
      end

      it "returns neutral" do
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end

    context "when value matches options" do
      before do
        field.instance_variable_set(:@options, {
          success: ["Done", :Complete],
          danger: :Cancelled,
          warning: ["On hold"],
          info: [:idea, "Idea"]
        })
      end

      it "returns success for 'Done'" do
        allow(field).to receive(:value).and_return("Done")
        expect(field.badge_color_for_value).to eq("success")
      end

      it "returns success for 'Complete' string" do
        allow(field).to receive(:value).and_return(:Complete)
        expect(field.badge_color_for_value).to eq("success")
      end

      it "returns danger for 'Cancelled'" do
        allow(field).to receive(:value).and_return("Cancelled")
        expect(field.badge_color_for_value).to eq("danger")
      end

      it "returns warning for 'On hold'" do
        allow(field).to receive(:value).and_return("On hold")
        expect(field.badge_color_for_value).to eq("warning")
      end

      it "returns info for 'Idea' string" do
        allow(field).to receive(:value).and_return("Idea")
        expect(field.badge_color_for_value).to eq("info")
      end
    end

    context "when value does not match options" do
      before do
        field.instance_variable_set(:@options, {
          success: ["Done"],
          danger: ["Cancelled"]
        })
      end

      it "returns neutral for unknown value" do
        allow(field).to receive(:value).and_return("unknown")
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end

    context "when options are empty" do
      before do
        field.instance_variable_set(:@options, {})
      end

      it "returns neutral for any value" do
        allow(field).to receive(:value).and_return("any_value")
        expect(field.badge_color_for_value).to eq("neutral")
      end
    end
  end

  describe "#color" do
    context "when explicit color is provided as a string" do
      before do
        field.instance_variable_set(:@color, "success")
      end

      it "returns the explicit color" do
        allow(field).to receive(:execute_context).with("success").and_return("success")
        expect(field.color).to eq("success")
      end
    end

    context "when explicit color is provided as a proc" do
      before do
        field.instance_variable_set(:@color, -> { "danger" })
      end

      it "executes the proc and returns the result" do
        allow(field).to receive(:execute_context).with(anything).and_return("danger")
        expect(field.color).to eq("danger")
      end
    end

    context "when no explicit color is provided" do
      before do
        field.instance_variable_set(:@color, nil)
        field.instance_variable_set(:@options, {})  # Empty options
        allow(field).to receive(:value).and_return(nil)  # Blank value
      end

      it "falls back to badge_color_for_value which defaults to neutral" do
        allow(field).to receive(:execute_context).with(nil).and_return(nil)
        expect(field.color).to eq("neutral") 
      end
    end
  end

  describe "#style" do
    context "when explicit style is provided" do
      before do
        field.instance_variable_set(:@style, "solid")
      end

      it "returns the explicit style" do
        allow(field).to receive(:execute_context).with("solid").and_return("solid")
        expect(field.style).to eq("solid")
      end
    end

    context "when style is provided as a proc" do
      before do
        field.instance_variable_set(:@style, -> { "solid" })
      end

      it "executes the proc and returns the result" do
        allow(field).to receive(:execute_context).with(anything).and_return("solid")
        expect(field.style).to eq("solid")
      end
    end

    context "when no explicit style is provided" do
      before do
        field.instance_variable_set(:@style, nil)
      end

      it "defaults to subtle" do
        allow(field).to receive(:execute_context).with(nil).and_return(nil)
        expect(field.style).to eq("subtle")
      end
    end
  end

  describe "#icon" do
    context "when icon is provided" do
      before do
        field.instance_variable_set(:@icon, "tabler/outline/check")
      end

      it "executes context and returns the icon" do
        allow(field).to receive(:execute_context).with("tabler/outline/check").and_return("tabler/outline/check")
        expect(field.icon).to eq("tabler/outline/check")
      end
    end

    context "when icon is provided as a proc" do
      before do
        field.instance_variable_set(:@icon, -> { "tabler/outline/alert" })
      end

      it "executes the proc and returns the result" do
        allow(field).to receive(:execute_context).with(anything).and_return("tabler/outline/alert")
        expect(field.icon).to eq("tabler/outline/alert")
      end
    end

    context "when no icon is provided" do
      before do
        field.instance_variable_set(:@icon, nil)
      end

      it "returns nil" do
        allow(field).to receive(:execute_context).with(nil).and_return(nil)
        expect(field.icon).to be_nil
      end
    end
  end

  describe "#options_for_filter" do
    context "when options contain arrays" do
      before do
        field.instance_variable_set(:@options, {
          success: ["Done", :Complete],
          danger: ["Cancelled"],
          warning: ["On hold", "Pending"]
        })
      end

      it "returns flattened unique values without converting to strings" do
        expect(field.options_for_filter).to match_array(["Done", :Complete, "Cancelled", "On hold", "Pending"])
      end
    end

    context "when options contain single values" do
      before do
        field.instance_variable_set(:@options, {
          success: :Done,
          danger: "Cancelled"
        })
      end

      it "returns the values without converting to strings" do
        expect(field.options_for_filter).to match_array([:Done, "Cancelled"])
      end
    end

    context "when options are empty" do
      before do
        field.instance_variable_set(:@options, {})
      end

      it "returns an empty array" do
        expect(field.options_for_filter).to eq([])
      end
    end
  end
end
