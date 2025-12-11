require "rails_helper"

RSpec.describe Avo::UI::BadgeComponent, type: :component do
  # Use centralized color definitions for consistent testing
  let(:colors) { Avo::UI::Colors::DEFINITIONS }
  let(:color_aliases) { Avo::UI::Colors::ALIASES }
  let(:valid_colors) { Avo::UI::Colors::ALL }
  describe "rendering" do
    it "renders default badge with secondary color" do
      render_inline(described_class.new(label: "Test Badge"))

      expect(page).to have_css(".inline-flex")
      expect(page).to have_css(".rounded-md")
      expect(page).to have_text("Test Badge")
      expect(page.find(".inline-flex")["style"]).to include("background-color: #F6F6F6")
      expect(page.find(".inline-flex")["style"]).to include("color: #171717")
    end

    it "renders badge without label" do
      render_inline(described_class.new(label: ""))

      expect(page).to have_css(".inline-flex")
      expect(page).not_to have_css("span.truncate")
    end

    it "renders badge with icon on the left" do
      render_inline(described_class.new(
        label: "With Icon",
        icon: "avo/paperclip"
      ))

      expect(page).to have_css("svg.w-3.h-3")
      expect(page).to have_text("With Icon")
    end

    it "renders badge with icon on the right" do
      render_inline(described_class.new(
        label: "Icon Right",
        icon: "avo/paperclip",
        icon_position: "right"
      ))

      expect(page).to have_css("svg")
      # Icon should come after the text in the DOM
      expect(page.text).to include("Icon Right")
    end
  end

  describe "color logic" do
    context "with subtle style (default)" do
      it "uses base color for semantic colors" do
        render_inline(described_class.new(
          label: "Success",
          color: "success",
          style: "subtle"
        ))

        success_color = colors['success']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{success_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{success_color[:text]}")
      end

      it "uses base color for full colors" do
        render_inline(described_class.new(
          label: "Purple",
          color: "purple",
          style: "subtle"
        ))

        purple_color = colors['purple']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{purple_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{purple_color[:text]}")
      end
    end

    context "with solid style" do
      it "uses -secondary variant for colors that support it" do
        render_inline(described_class.new(
          label: "Purple",
          color: "purple",
          style: "solid"
        ))

        # Should use purple-secondary (dark bg, light text) from centralized colors
        purple_secondary = colors['purple-secondary']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{purple_secondary[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{purple_secondary[:text]}")
      end

      it "uses base color for semantic colors (no -secondary variant)" do
        render_inline(described_class.new(
          label: "Success",
          color: "success",
          style: "solid"
        ))

        # Success doesn't have -secondary, so use base color from centralized colors
        success_color = colors['success']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{success_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{success_color[:text]}")
      end

      Avo::UI::Colors::DEFINITIONS.keys.select { |k| k.include?("-secondary") }.each do |color_key|
        base_color = color_key.gsub("-secondary", "")

        it "uses -secondary variant for #{base_color}" do
          render_inline(described_class.new(
            label: "Test",
            color: base_color,
            style: "solid"
          ))

          secondary_def = Avo::UI::Colors::DEFINITIONS[color_key]
          expect(page.find(".inline-flex")["style"]).to include("background-color: #{secondary_def[:bg]}")
          expect(page.find(".inline-flex")["style"]).to include("color: #{secondary_def[:text]}")
        end
      end
    end

    context "with color aliases" do
      it "maps 'info' to 'informative'" do
        render_inline(described_class.new(
          label: "Info",
          color: "info"
        ))

        informative_color = colors['informative']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{informative_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{informative_color[:text]}")
      end

      it "maps 'danger' to 'error'" do
        render_inline(described_class.new(
          label: "Danger",
          color: "danger"
        ))

        error_color = colors['error']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{error_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{error_color[:text]}")
      end
    end

    context "with invalid color" do
      it "falls back to 'secondary'" do
        render_inline(described_class.new(
          label: "Invalid",
          color: "rainbow"
        ))

        # Should use secondary color from centralized definitions
        secondary_color = colors['secondary']
        expect(page.find(".inline-flex")["style"]).to include("background-color: #{secondary_color[:bg]}")
        expect(page.find(".inline-flex")["style"]).to include("color: #{secondary_color[:text]}")
      end

      it "does not raise an error" do
        expect {
          render_inline(described_class.new(
            label: "Test",
            color: "nonexistent_color"
          ))
        }.not_to raise_error
      end
    end
  end

  describe "parameter validation" do
    it "raises error for invalid style" do
      expect {
        described_class.new(label: "Test", style: "invalid")
      }.to raise_error(ArgumentError, /Invalid style/)
    end

    it "raises error for invalid icon position" do
      expect {
        described_class.new(label: "Test", icon_position: "center")
      }.to raise_error(ArgumentError, /Invalid icon_position/)
    end

    it "accepts all valid styles" do
      described_class::STYLES.each do |style|
        expect {
          render_inline(described_class.new(label: "Test", style: style))
        }.not_to raise_error
      end
    end

    it "accepts all valid colors" do
      colors.keys.each do |color|
        expect {
          render_inline(described_class.new(label: "Test", color: color))
        }.not_to raise_error
      end
    end

    it "accepts all color aliases" do
      color_aliases.keys.each do |alias_name|
        expect {
          render_inline(described_class.new(label: "Test", color: alias_name))
        }.not_to raise_error
      end
    end
  end

  describe "all color variants" do
    context "semantic colors" do
      %w[secondary success error warning informative].each do |color|
        it "renders #{color} badge correctly" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color
          ))

          color_def = colors[color]
          expect(page.find(".inline-flex")["style"]).to include("background-color: #{color_def[:bg]}")
          expect(page.find(".inline-flex")["style"]).to include("color: #{color_def[:text]}")
        end
      end
    end

    context "full colors with variants" do
      %w[orange yellow green teal blue purple].each do |color|
        it "renders #{color} subtle style correctly" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color,
            style: "subtle"
          ))

          color_def = colors[color]
          expect(page.find(".inline-flex")["style"]).to include("background-color: #{color_def[:bg]}")
          expect(page.find(".inline-flex")["style"]).to include("color: #{color_def[:text]}")
        end

        it "renders #{color} solid style correctly" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color,
            style: "solid"
          ))

          color_def = colors["#{color}-secondary"]
          expect(page.find(".inline-flex")["style"]).to include("background-color: #{color_def[:bg]}")
          expect(page.find(".inline-flex")["style"]).to include("color: #{color_def[:text]}")
        end
      end
    end
  end

  describe "icon rendering" do
    it "does not render icon when not provided" do
      render_inline(described_class.new(label: "No Icon"))

      expect(page).not_to have_css("svg")
    end

    it "renders icon with correct size classes" do
      render_inline(described_class.new(
        label: "Test",
        icon: "avo/paperclip"
      ))

      expect(page).to have_css("svg.w-3.h-3")
    end

    it "applies shrink-0 to prevent icon squishing" do
      render_inline(described_class.new(
        label: "Test",
        icon: "avo/paperclip"
      ))

      expect(page).to have_css("svg.shrink-0")
    end
  end

  describe "edge cases" do
    it "handles nil label gracefully" do
      expect {
        render_inline(described_class.new(label: nil))
      }.not_to raise_error
    end

    it "handles empty string label" do
      render_inline(described_class.new(label: ""))

      expect(page).to have_css(".inline-flex")
      expect(page).not_to have_css("span.truncate")
    end

    it "handles very long label text" do
      long_label = "A" * 100
      render_inline(described_class.new(label: long_label))

      expect(page).to have_css("span.truncate")
      expect(page).to have_text(long_label)
    end

    it "handles icon without label" do
      render_inline(described_class.new(
        label: "",
        icon: "avo/paperclip"
      ))

      expect(page).to have_css("svg")
      expect(page).not_to have_css("span.truncate")
    end
  end
end

