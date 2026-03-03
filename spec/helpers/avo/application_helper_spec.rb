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
      colors = Avo.configuration.branding.chart_colors
      colors_length = colors.length

      # Test that index wraps around correctly using modulo
      expect(helper.chart_color(20)).to eq(colors[20 % colors_length])
      expect(helper.chart_color(55)).to eq(colors[55 % colors_length])

      # Verify it wraps to the beginning when index equals array length
      expect(helper.chart_color(colors_length)).to eq(colors[0])
    end
  end

  describe "#input_classes" do
    it "adds error class when has_error is true" do
      classes = helper.input_classes("", has_error: true)
      expect(classes).to include("input-field--error")
    end

    it "includes extra classes" do
      classes = helper.input_classes("custom-class another-class")
      expect(classes).to include("custom-class")
      expect(classes).to include("another-class")
    end

    describe "size variants" do
      it "adds sm size class when size is :sm" do
        classes = helper.input_classes("", size: :sm)
        expect(classes).to include("input--size-sm")
      end

      it "adds md size class when size is :md" do
        classes = helper.input_classes("", size: :md)
        expect(classes).to include("input--size-md")
      end

      it "adds lg size class when size is :lg" do
        classes = helper.input_classes("", size: :lg)
        expect(classes).to include("input--size-lg")
      end

      it "defaults to md size when size is not specified" do
        classes = helper.input_classes("")
        expect(classes).to include("input--size-md")
      end

      it "does not add size class for invalid size values" do
        classes = helper.input_classes("", size: :invalid)
        expect(classes).to eq("")
        expect(classes).not_to include("input--size-invalid")
        expect(classes).not_to include("input--size-md")
      end
    end
  end
end
