require "rails_helper"

RSpec.describe Avo::UI::BadgeComponent, type: :component do
  let(:color_aliases) { Avo::UI::Colors::ALIASES }
  let(:valid_colors) { Avo::UI::Colors::VALID_COLORS }
  describe "rendering" do
    it "renders default badge with secondary color" do
      render_inline(described_class.new(label: "Test Badge"))

      expect(page).to have_css(".badge")
      expect(page).to have_text("Test Badge")
      # Check for correct CSS classes (colors are now handled via CSS variables in classes)
      expect(page).to have_css(".badge--subtle.badge--secondary")
    end

    it "renders badge without label" do
      render_inline(described_class.new(label: ""))

      expect(page).to have_css(".badge")
      expect(page).not_to have_css(".badge__label")
    end

    it "renders badge with icon on the left" do
      render_inline(described_class.new(
        label: "With Icon",
        icon: "avo/paperclip"
      ))

      expect(page).to have_css(".badge__icon")
      expect(page).to have_text("With Icon")
    end
  end

  describe "color logic" do
    context "with subtle style (default)" do
      it "uses correct CSS classes for semantic colors" do
        render_inline(described_class.new(
          label: "Success",
          color: "success",
          style: "subtle"
        ))

        # Check for correct CSS classes (colors use CSS variables)
        expect(page).to have_css(".badge--subtle.badge--success")
      end

      it "uses correct CSS classes for full colors" do
        render_inline(described_class.new(
          label: "Purple",
          color: "purple",
          style: "subtle"
        ))

        # Check for correct CSS classes (colors use CSS variables)
        expect(page).to have_css(".badge--subtle.badge--purple")
      end
    end

    context "with solid style" do
      it "uses correct CSS classes for colors that support solid style" do
        render_inline(described_class.new(
          label: "Purple",
          color: "purple",
          style: "solid"
        ))

        # Should have solid style class and color class (colors use CSS variables)
        expect(page).to have_css(".badge--solid.badge--purple")
      end

      it "semantic colors do not support solid style (only subtle)" do
        render_inline(described_class.new(
          label: "Success",
          color: "success",
          style: "solid"
        ))

        # Component will apply .badge--solid.badge--success classes,
        # but CSS only defines .badge--subtle.badge--success
        # So the solid style won't have any CSS rules and won't render correctly
        expect(page).to have_css(".badge--solid.badge--success")
        # Verify that there's no CSS rule for this combination by checking
        # that it doesn't match the subtle style (which is what semantic colors support)
        expect(page).not_to have_css(".badge--subtle.badge--success")
        # Note: This test documents that semantic colors (success, error, warning, informative, secondary)
        # only support subtle style, not solid style. The component will still apply the classes,
        # but there's no matching CSS, so it won't render with proper solid styling.
      end

      # Test solid style for colors that support it (orange, yellow, green, teal, blue, purple)
      %w[orange yellow green teal blue purple].each do |base_color|
        it "uses solid style for #{base_color}" do
          render_inline(described_class.new(
            label: "Test",
            color: base_color,
            style: "solid"
          ))

          # Should have solid style class and color class
          expect(page).to have_css(".badge.badge--solid.badge--#{base_color}")
        end
      end
    end

    context "with color aliases" do
      it "maps 'info' to 'informative'" do
        render_inline(described_class.new(
          label: "Info",
          color: "info"
        ))

        # Should use informative color class (colors use CSS variables)
        expect(page).to have_css(".badge--subtle.badge--informative")
      end

      it "maps 'danger' to 'error'" do
        render_inline(described_class.new(
          label: "Danger",
          color: "danger"
        ))

        # Should use error color class (colors use CSS variables)
        expect(page).to have_css(".badge--subtle.badge--error")
      end
    end

    context "with invalid color" do
      it "falls back to 'secondary'" do
        render_inline(described_class.new(
          label: "Invalid",
          color: "rainbow"
        ))

        # Should use secondary color class (colors use CSS variables)
        expect(page).to have_css(".badge--subtle.badge--secondary")
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

    it "accepts all valid styles" do
      described_class::STYLES.each do |style|
        expect {
          render_inline(described_class.new(label: "Test", style: style))
        }.not_to raise_error
      end
    end

    it "accepts all valid colors" do
      valid_colors.each do |color|
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
        it "renders #{color} badge correctly with CSS classes" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color
          ))

          # Check for correct CSS classes (colors use CSS variables)
          color_class = (color == "secondary") ? "default" : color
          expect(page).to have_css(".badge--subtle.badge--#{color_class}")
        end
      end
    end

    context "full colors with variants" do
      %w[orange yellow green teal blue purple].each do |color|
        it "renders #{color} subtle style correctly with CSS classes" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color,
            style: "subtle"
          ))

          # Check for correct CSS classes (colors use CSS variables)
          expect(page).to have_css(".badge--subtle.badge--#{color}")
        end

        it "renders #{color} solid style correctly with CSS classes" do
          render_inline(described_class.new(
            label: color.capitalize,
            color: color,
            style: "solid"
          ))

          # Check for correct CSS classes (colors use CSS variables)
          expect(page).to have_css(".badge--solid.badge--#{color}")
        end
      end
    end
  end

  describe "icon rendering" do
    it "does not render icon when not provided" do
      render_inline(described_class.new(label: "No Icon"))

      expect(page).not_to have_css("svg")
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

      expect(page).to have_css(".badge")
      expect(page).not_to have_css("span.truncate")
    end

    it "handles very long label text" do
      long_label = "A" * 100
      render_inline(described_class.new(label: long_label))

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
