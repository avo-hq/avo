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

  describe "#safe_blob_path and #safe_blob_url" do
    def create_image_blob(filename: "keep.jpg")
      ActiveStorage::Blob.create_and_upload!(
        io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open,
        filename: filename,
        content_type: "image/jpeg"
      )
    end

    it "returns routable URLs for blobs with a blank filename" do
      blob = create_image_blob
      blob.update_column(:filename, "")

      path = helper.safe_blob_path(blob)
      url = helper.safe_blob_url(blob)

      expect(path).to include("/rails/active_storage/blobs/redirect/")
      expect(path).to include("attachment.jpg")
      expect(url).to include("/rails/active_storage/blobs/redirect/")
      expect(url).to include("attachment.jpg")
    end

    it "returns normal URLs for blobs with a filename" do
      blob = create_image_blob(filename: "photo.jpg")

      path = helper.safe_blob_path(blob)
      url = helper.safe_blob_url(blob)

      expect(path).to include("photo.jpg")
      expect(url).to include("photo.jpg")
    end

    it "returns routable representation URLs for variants of blobs with a blank filename" do
      blob = create_image_blob
      blob.update_column(:filename, "")

      url = helper.safe_blob_representation_url(blob.variant(resize_to_limit: [600, 600]))

      expect(url).to include("/rails/active_storage/representations/redirect/")
      expect(url).to include("attachment.jpg")
    end
  end

  describe "#avo_appearance_t" do
    before do
      I18n.backend.store_translations(:en, avo: {appearance: {test_fallback_key: "English only"}})
    end

    it "falls back to English when the active locale omits appearance keys" do
      I18n.with_locale(:de) do
        expect(helper.avo_appearance_t("test_fallback_key")).to eq("English only")
      end
    end

    it "returns plain text safe for HTML attributes" do
      result = helper.avo_appearance_t("auto_tooltip")

      expect(result).not_to include("<")
      expect(result).not_to include("translation_missing")
      expect(result).not_to include('">')
    end

    it "uses the explicit default when the key is missing in both locales" do
      expect(helper.avo_appearance_t("neutrals_list.unknown", default: "Fallback")).to eq("Fallback")
    end
  end

  describe "#appearance_neutral_labels" do
    it "returns a label map keyed by neutral theme name" do
      labels = helper.appearance_neutral_labels(%w[brand slate])

      expect(labels).to eq({"brand" => "Brand", "slate" => "Slate"})
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

    # `action_name` is a controller method exposed to views in real requests but
    # isn't defined on ActionView::Base, so `verify_partial_doubles` rejects
    # `allow(helper).to receive(:action_name)`. Define it on the helper's
    # singleton class instead so the stub is real.
    def stub_action_name(name)
      helper.define_singleton_method(:action_name) { name }
    end

    it "maps update to resource-edit-view" do
      stub_action_name("update")

      expect(helper.body_classes).to include("resource-edit-view")
    end

    it "maps create to resource-new-view" do
      stub_action_name("create")

      expect(helper.body_classes).to include("resource-new-view")
    end
  end

  describe "#container_classes" do
    it "falls back to lg for unrecognized views" do
      helper.instance_variable_set(:@view, "preview")

      expect(helper.container_classes).to eq("container-lg")
    end
  end

  # Unit 2 / R17. The `avo.sidebar.width` cookie is user-controlled input (and
  # not only the admin's — a sibling subdomain, a plaintext MITM, or the host
  # app can set it). #sidebar_width is the whole trust boundary: it must return
  # an Integer within bounds or nil, and must never raise. See
  # docs/plans/2026-07-24-001-feat-resizable-sidebar-plan.md (Unit 2).
  describe "#sidebar_width" do
    def with_cookie(value)
      allow(helper).to receive(:cookies).and_return({"avo.sidebar.width" => value})
      helper.send(:sidebar_width)
    end

    it "returns the Integer width for a valid in-bounds cookie" do
      expect(with_cookie("384")).to eq(384)
      expect(with_cookie("384")).to be_a(Integer)
    end

    it "returns nil when no cookie is set (R9: existing users keep 256px)" do
      allow(helper).to receive(:cookies).and_return({})
      expect(helper.send(:sidebar_width)).to be_nil
    end

    # The highest-severity case: Rack hands a UTF-8-tagged String with invalid
    # bytes for `avo.sidebar.width=%C3%28`. Without the valid_encoding? guard the
    # subsequent blank?/match? raises ArgumentError — a 500 on every admin page.
    it "returns nil without raising for an invalid UTF-8 byte sequence" do
      invalid = "\xC3\x28".dup.force_encoding("UTF-8")
      expect(invalid.valid_encoding?).to be(false) # sanity: really invalid

      expect { with_cookie(invalid) }.not_to raise_error
      expect(with_cookie(invalid)).to be_nil
    end

    # Every rejected input maps to nil. Note the traps: "400abc" must not yield
    # 400, "1e9" must not yield 1, the `^`/`$` anchor trap must be rejected, and
    # the Arabic-Indic / fullwidth digits must be nil (not 0 -> clamp -> 200).
    [
      ["", "empty string"],
      ["abc", "non-numeric"],
      ["400abc", "trailing garbage (must NOT parse to 400)"],
      ["1e9", "scientific notation (must NOT parse to 1)"],
      ["-50", "negative sign"],
      ["+200", "leading plus (Integer() would accept)"],
      ["2_0_0", "underscore digit grouping (Integer() would accept)"],
      [" 200 ", "surrounding whitespace (Integer() would accept)"],
      ["200\n<script>alert(1)</script>", "the ^/$ anchor trap"],
      ["٤٨٠", "Arabic-Indic digits (to_i would give 0 -> 200)"],
      ["４８０", "fullwidth digits (to_i would give 0 -> 200)"],
      ["1" * 5000, "oversize value caught by the bytesize guard"]
    ].each do |value, description|
      it "returns nil for #{description}" do
        expect(with_cookie(value)).to be_nil
      end
    end

    it "clamps below the minimum up to SIDEBAR_WIDTH_MIN (R10)" do
      expect(with_cookie("50")).to eq(200)
    end

    it "clamps above the maximum down to SIDEBAR_WIDTH_MAX (R10)" do
      expect(with_cookie("9999")).to eq(480)
    end

    it "always returns an Integer or nil, never a String (the type invariant)" do
      inputs = ["384", "", "abc", "400abc", "-50", "+200", "2_0_0", " 200 ",
        "200\n<script>", "٤٨٠", "４８０", "50", "9999", ("1" * 5000)]
      inputs.each do |value|
        result = with_cookie(value)
        expect(result).to be_a(Integer).or(be_nil), "expected Integer|nil for #{value.inspect}, got #{result.class}"
      end
    end

    it "handles a non-String value from the cookie jar without raising" do
      # Rails' cookie jar can cache an assigned non-String value; .to_s guards it.
      allow(helper).to receive(:cookies).and_return({"avo.sidebar.width" => 384})
      expect { helper.send(:sidebar_width) }.not_to raise_error
      expect(helper.send(:sidebar_width)).to eq(384)
    end
  end

  describe "#sidebar_width_min / #sidebar_width_max" do
    it "expose the pixel bounds for the JS layer" do
      expect(helper.sidebar_width_min).to eq(200)
      expect(helper.sidebar_width_max).to eq(480)
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
