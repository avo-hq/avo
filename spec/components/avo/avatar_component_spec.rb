require "rails_helper"

RSpec.describe Avo::UI::AvatarComponent, type: :component do
  describe "rendering" do
    it "renders the placeholder avatar by default" do
      result = render_inline(described_class.new)

      expect(result).to have_css(".cado-avatar")
      expect(result).to have_css(".cado-avatar--placeholder")
      expect(result).to have_css(".cado-avatar--large")
      expect(result).to have_css(".cado-avatar--rounded")
      expect(result).to have_css(".cado-avatar__border")
    end

    it "renders an image avatar" do
      result = render_inline(described_class.new(
        type: "avatar",
        src: "/test-image.jpg",
        alt: "Test User"
      ))

      expect(result).to have_css(".cado-avatar--avatar")
      expect(result).to have_css(".cado-avatar__image")
      expect(result).to have_css("img.cado-avatar__img[src='/test-image.jpg'][alt='Test User']")
      expect(result).not_to have_css(".cado-avatar__border")
    end

    it "renders initials" do
      result = render_inline(described_class.new(
        type: "initials",
        initials: "JD"
      ))

      expect(result).to have_css(".cado-avatar--initials")
      expect(result).to have_css(".cado-avatar__initials", text: "J")
      expect(result).to have_css(".cado-avatar__border")
    end

    it "applies themed colors without border" do
      result = render_inline(described_class.new(
        type: "initials",
        initials: "A",
        theme: "blue"
      ))

      expect(result).to have_css(".cado-avatar--blue")
      expect(result).not_to have_css(".cado-avatar__border")
    end

    it "renders all supported sizes" do
      described_class::SIZES.each do |size|
        result = render_inline(described_class.new(size: size))
        expect(result).to have_css(".cado-avatar--#{size}")
      end
    end

    it "renders all supported shapes" do
      described_class::SHAPES.each do |shape|
        result = render_inline(described_class.new(shape: shape))
        expect(result).to have_css(".cado-avatar--#{shape}")
      end
    end

    it "passes through global options" do
      result = render_inline(described_class.new(
        id: "my-avatar",
        data: {testid: "avatar-component"}
      ))

      expect(result).to have_css(".cado-avatar#my-avatar[data-testid='avatar-component']")
    end
  end

  describe "parameter validation" do
    it "requires initials when type is initials" do
      expect do
        described_class.new(type: "initials")
      end.to raise_error(ArgumentError, "Initials is required when type is 'initials'")
    end

    it "requires src when type is avatar" do
      expect do
        described_class.new(type: "avatar")
      end.to raise_error(ArgumentError, "src is required when type is 'avatar'")
    end

    it "rejects invalid enum values" do
      expect { described_class.new(type: "invalid") }.to raise_error(ArgumentError, "Invalid type: invalid")
      expect { described_class.new(size: "huge") }.to raise_error(ArgumentError, "Invalid size: huge")
      expect { described_class.new(shape: "triangle") }.to raise_error(ArgumentError, "Invalid shape: triangle")
      expect { described_class.new(theme: "rainbow") }.to raise_error(ArgumentError, "Invalid theme: rainbow")
    end
  end

  describe "#display_initials" do
    it "returns the first character uppercased" do
      component = described_class.new(type: "initials", initials: "JD")
      expect(component.send(:display_initials)).to eq "JD"
    end

    it "handles lowercase initials" do
      component = described_class.new(type: "initials", initials: "J")
      expect(component.send(:display_initials)).to eq "J"
    end

    it "returns empty string when initials missing" do
      component = described_class.new(type: "placeholder")
      expect(component.send(:display_initials)).to eq ""
    end
  end
end
