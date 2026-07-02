require "rails_helper"

RSpec.describe Avo::Views::ResourceIndexComponent, type: :component do
  let(:resource) { Avo::Resources::User.new(view: Avo::ViewInquirer.new("index")) }
  let(:component) { described_class.new(resource:, resources: []) }

  describe "#can_render_scopes?" do
    before do
      allow(Avo.plugin_manager).to receive(:installed?).and_call_original
      allow(Avo.plugin_manager).to receive(:installed?).with("avo-scopes").and_return(true)
    end

    it "returns false when there are no scopes" do
      expect(component.send(:can_render_scopes?)).to be(false)
    end

    it "returns true when scopes are present" do
      component_with_scopes = described_class.new(resource:, resources: [], scopes: [:all])

      expect(component_with_scopes.send(:can_render_scopes?)).to be(true)
    end
  end
end
