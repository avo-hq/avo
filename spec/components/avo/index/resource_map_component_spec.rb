# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Avo::Index::ResourceMapComponent, type: :component do
  # it "renders something useful" do
  #   expect(
  #     render_inline(described_class.new(attr: "value")) { "Hello, components!" }.css("p").to_html
  #   ).to include(
  #     "Hello, components!"
  #   )
  # end

  describe '#resource_location_markers' do
    let(:component) { described_class.new}
    let(:resource1) { double(record: record1) }
    let(:record1) { double(coordinates: [1, 2]) }
    let(:resource2) { double(record: record2) }
    let(:record2) { double(coordinates: [3, 4]) }
    let(:resource3) { double(record: record3) }
    let(:record3) { double(coordinates: nil) }
    let(:resource4) { double(record: record4) }
    let(:record4) { double(coordinates: []) }

    it 'returns an array of marker hashes'

    it 'skips resources without coordinates'
  end
end
