require "rails_helper"

RSpec.describe Avo::ViewTypes::ViewTypeManager do
  let(:manager) { described_class.new.tap(&:reset) }

  it "resolves the default view types to their components" do
    expect(manager.component_for(:table)).to eq Avo::ViewTypes::TableComponent
    expect(manager.component_for(:grid)).to eq Avo::ViewTypes::GridComponent
    expect(manager.component_for(:map)).to eq Avo::ViewTypes::MapComponent
    expect(manager.component_for(:list)).to eq Avo::ViewTypes::TableComponent
  end
end
