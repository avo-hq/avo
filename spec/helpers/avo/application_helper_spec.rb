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
end
