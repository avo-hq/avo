require "rails_helper"

# The thirteen built-ins and the one stylesheet they share. A block that
# forgets a required token ships a theme that silently inherits the previous
# theme's value on hover, so the required set is checked per theme here.
RSpec.describe Avo::BuiltinThemes do
  let(:css) { Avo::Engine.root.join("app/assets/stylesheets/avo/themes.css").read }

  def block_for(theme, dark: false)
    selector = dark ? "#{Regexp.escape(".#{theme.css_class}.dark")},\\s*\\.dark\\s+\\.#{Regexp.escape(theme.css_class)}" : Regexp.escape(".#{theme.css_class}")
    match = css.match(/^  #{selector} \{\n(.*?)\n  \}/m)
    match && match[1]
  end

  it "ships thirteen themes with Paper first" do
    expect(described_class.ids).to eq(%i[paper coastal rose sunset midnight monokai dracula solarized nord gruvbox one_dark catppuccin tokyo_night])
    expect(described_class.all).to all(be_builtin)
    expect(described_class.all.map(&:stylesheet)).to all(be_nil)
  end

  it "keeps Paper as the defaults: no block in the stylesheet" do
    expect(block_for(described_class::Paper)).to be_nil
  end

  described_class.all.reject { |t| t == described_class::Paper }.each do |theme|
    describe theme.title do
      it "declares every required token in its light block, inside @layer base" do
        light = block_for(theme)
        expect(light).to be_present, "no light block for #{theme.css_class}"

        Avo::Themes::Catalog.required.each do |token|
          expect(light).to include("#{token.name}:"), "#{theme.css_class} light block is missing #{token.name}"
        end
        expect(light).to include("--color-brand-accent:")
        expect(light).to include("--color-brand-neutral-400:")
      end

      it "declares the accent trio in its dark block" do
        dark = block_for(theme, dark: true)
        expect(dark).to be_present, "no dark block for #{theme.css_class}"

        %w[--color-accent --color-accent-content --color-accent-foreground --color-brand-accent].each do |name|
          expect(dark).to include("#{name}:"), "#{theme.css_class} dark block is missing #{name}"
        end
      end

      it "re-states the dark foundations for any foundation it sets in light" do
        light = block_for(theme)
        dark = block_for(theme, dark: true)
        %w[--color-primary --color-background --color-secondary --color-tertiary --color-content --color-content-secondary].each do |name|
          next unless light.include?("#{name}:")

          expect(dark).to include("#{name}:"), "#{theme.css_class} sets #{name} in light but not in dark; the light value would leak into dark mode"
        end
      end
    end
  end

  it "credits every editor palette" do
    editor_themes = described_class.all.drop(5)
    expect(editor_themes.map(&:attribution)).to all(be_present)
    notice = Avo::Engine.root.join("NOTICE").read
    editor_themes.each { |theme| expect(notice).to include(theme.title.split.first) }
  end

  it "declares only @layer base rules" do
    expect(css.scan(/^@layer (\w+)/).flatten.uniq).to eq(["base"])
  end
end
