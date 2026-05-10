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
      expect(helper.chart_color(0)).to eq(Avo.configuration.appearance.chart_colors[0])
      expect(helper.chart_color(5)).to eq(Avo.configuration.appearance.chart_colors[5])
    end

    it "starts the list of colors again if index is higher than the amount of defined colors" do
      colors = Avo.configuration.appearance.chart_colors
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

  describe "#body_classes" do
    before do
      allow(helper).to receive(:request).and_return(double(user_agent: "Mozilla/5.0"))
      allow(helper).to receive(:controller).and_return(double(class: double(superclass: Avo::ResourcesController)))
    end

    it "maps update to resource-edit-view" do
      allow(helper).to receive(:action_name).and_return("update")

      expect(helper.body_classes).to include("resource-edit-view")
    end

    it "maps create to resource-new-view" do
      allow(helper).to receive(:action_name).and_return("create")

      expect(helper.body_classes).to include("resource-new-view")
    end
  end

  describe "#container_classes" do
    it "falls back to large for unrecognized views" do
      helper.instance_variable_set(:@view, "preview")

      expect(helper.container_classes).to eq("container-large")
    end
  end

  describe "appearance helpers honor lock configuration" do
    let(:appearance) { Avo.configuration.appearance }

    describe "#current_neutral" do
      context "when neutral is locked" do
        before do
          allow(appearance).to receive(:neutral_locked?).and_return(true)
          allow(appearance).to receive(:neutral).and_return(:brand)
        end

        it "ignores the cookie override and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(helper).to receive(:cookies).and_return({theme: "slate"})

          expect(helper.send(:current_neutral)).to eq("brand")
        end

        it "ignores the database-persisted value and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(true)
          Avo::Current.appearance_settings = {neutral: "slate"}

          expect(helper.send(:current_neutral)).to eq("brand")
        end
      end

      context "when neutral is not locked" do
        before do
          allow(appearance).to receive(:neutral_locked?).and_return(false)
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(appearance).to receive(:neutral).and_return(:brand)
        end

        it "respects the cookie override" do
          allow(helper).to receive(:cookies).and_return({theme: "slate"})

          expect(helper.send(:current_neutral)).to eq("slate")
        end
      end
    end

    describe "#current_accent" do
      context "when accent is locked" do
        before do
          allow(appearance).to receive(:accent_locked?).and_return(true)
          allow(appearance).to receive(:accent).and_return(:brand)
        end

        it "ignores the cookie override and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(helper).to receive(:cookies).and_return({accent_color: "blue"})

          expect(helper.send(:current_accent)).to eq("brand")
        end

        it "ignores the database-persisted value and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(true)
          Avo::Current.appearance_settings = {accent: "blue"}

          expect(helper.send(:current_accent)).to eq("brand")
        end
      end

      context "when accent is not locked" do
        before do
          allow(appearance).to receive(:accent_locked?).and_return(false)
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(appearance).to receive(:accent).and_return(:brand)
        end

        it "respects the cookie override" do
          allow(helper).to receive(:cookies).and_return({accent_color: "blue"})

          expect(helper.send(:current_accent)).to eq("blue")
        end
      end
    end

    describe "#current_scheme" do
      context "when scheme is locked" do
        before do
          allow(appearance).to receive(:scheme_locked?).and_return(true)
          allow(appearance).to receive(:scheme).and_return(:light)
        end

        it "ignores the cookie override and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(helper).to receive(:cookies).and_return({color_scheme: "dark"})

          expect(helper.send(:current_scheme)).to eq("light")
        end

        it "ignores the database-persisted value and returns the configured value" do
          allow(appearance).to receive(:database_persistence?).and_return(true)
          Avo::Current.appearance_settings = {color_scheme: "dark"}

          expect(helper.send(:current_scheme)).to eq("light")
        end
      end

      context "when scheme is not locked" do
        before do
          allow(appearance).to receive(:scheme_locked?).and_return(false)
          allow(appearance).to receive(:database_persistence?).and_return(false)
          allow(appearance).to receive(:scheme).and_return(:auto)
        end

        it "respects the cookie override" do
          allow(helper).to receive(:cookies).and_return({color_scheme: "dark"})

          expect(helper.send(:current_scheme)).to eq("dark")
        end
      end
    end
  end
end
