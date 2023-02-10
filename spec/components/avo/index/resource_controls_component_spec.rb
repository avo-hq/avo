require "rails_helper"

RSpec.describe Avo::Index::ResourceControlsComponent, type: :component do
  describe "#can_reorder?" do
    context "when @reflection is present" do
      it "returns the result of authorize_association_for" do
        component = described_class.new(reflection: true)
        allow(component).to receive(:authorize_association_for).with(:reorder).and_return(true)
        expect(component.can_reorder?).to eq(true)
      end
    end

    context "when @reflection is not present" do
      it "returns the result of authorize_action" do
        authorization = double(:authorization, authorize_action: true)
        component = described_class.new(resource: double(:resource, authorization: authorization))
        expect(component.can_reorder?).to eq(true)
      end
    end
  end
end
