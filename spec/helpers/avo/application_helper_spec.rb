require "rails_helper"

RSpec.describe Avo::ApplicationHelper do
  context "handling filter params" do
    let(:params) {
      {
        "q" => {
          "name" => "test"
        }
      }
    }
    let(:encoded_params) { Base64.encode64(params.to_json) }

    describe "#decode_filter_params" do
      it "decodes encoded params" do
        expect(helper.decode_filter_params(encoded_params)).to eq(params)
      end
    end

    describe "#encode_filter_params" do
      it "encodes params" do
        expect(helper.encode_filter_params(params)).to eq(encoded_params)
      end
    end
  end

  describe "#chart_color" do
    it "returns a color from the list of configured chart_colors" do
      expect(helper.chart_color(0)).to eq(Avo.configuration.branding.chart_colors[0])
      expect(helper.chart_color(5)).to eq(Avo.configuration.branding.chart_colors[5])
    end

    it "starts the list of colors again if index is higher than the amount of defined colors" do
      expect(helper.chart_color(20)).to eq(Avo.configuration.branding.chart_colors[0])
      expect(helper.chart_color(55)).to eq(Avo.configuration.branding.chart_colors[15])
    end
  end
end
