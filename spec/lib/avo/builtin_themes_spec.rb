require "rails_helper"

# The eighteen built-ins and the one stylesheet they share. Each theme is one
# block drawn for one scheme. A block that forgets a required token ships a
# theme that silently inherits the previous theme's value on hover, and one
# that forgets its foundations draws a wrong preview tile on a page in the
# other scheme, so both sets are checked per theme here.
RSpec.describe Avo::BuiltinThemes do
  let(:css) { Avo::Engine.root.join("app/assets/stylesheets/avo/themes.css").read }

  def block_for(theme)
    match = css.match(/^  #{Regexp.escape(".#{theme.css_class}")} \{\n(.*?)\n  \}/m)
    match && match[1]
  end

  it "ships eighteen themes with Paper first" do
    expect(described_class.ids).to eq(%i[
      paper coastal rose sunset midnight monokai dracula nord
      solarized_light solarized_dark gruvbox_light gruvbox_dark one_light one_dark
      catppuccin_latte catppuccin_mocha tokyo_night_day tokyo_night
    ])
    expect(described_class.all).to all(be_builtin)
    expect(described_class.all.map(&:stylesheet)).to all(be_nil)
  end

  it "keeps Paper as the defaults: no block, no locks, the user's scheme" do
    expect(block_for(described_class::Paper)).to be_nil
    expect(described_class::Paper.lock).to eq([])
    expect(described_class::Paper).not_to be_forces_scheme
  end

  it "makes every other theme a finished look: every picker locked, one scheme" do
    others = described_class.all - [described_class::Paper]

    expect(others.map(&:lock)).to all(eq(Avo::BaseTheme::LOCKABLE))
    expect(others).to all(be_forces_scheme)
    expect(others.select(&:dark?).map(&:id)).to eq(%i[midnight monokai dracula nord solarized_dark gruvbox_dark one_dark catppuccin_mocha tokyo_night])
  end

  it "has no .dark blocks: a theme is drawn for one scheme" do
    selectors = css.lines.grep(/^\s+\.[\w.-]+.*\{$/).map(&:strip)
    expect(selectors).to all(match(/\A\.avo-theme-\w+ \{\z/))
  end

  described_class.all.reject { |t| t == described_class::Paper }.each do |theme|
    describe theme.title do
      let(:block) { block_for(theme) }

      it "declares every required token in its block" do
        expect(block).to be_present, "no block for #{theme.css_class}"

        Avo::Themes::Catalog.required.each do |token|
          expect(block).to include("#{token.name}:"), "#{theme.css_class} is missing #{token.name}"
        end
        expect(block).to include("--color-brand-accent:")
        expect(block).to include("--color-brand-neutral-400:")
      end

      it "sets the foundations the preview tile reads, so the tile is right on a page in the other scheme" do
        %w[--color-background --color-primary --color-navbar-background].each do |name|
          expect(block).to include("#{name}:"), "#{theme.css_class} is missing #{name}"
        end
      end

      it "sets the dark surfaces when dark", if: theme.dark? do
        %w[--color-secondary --color-tertiary --color-content --color-content-secondary --color-sidebar-background].each do |name|
          expect(block).to include("#{name}:"), "#{theme.css_class} is dark but does not set #{name}"
        end
      end
    end
  end

  it "keeps a light navbar on a few light themes, with the navbar's own ink" do
    %i[coastal solarized_light gruvbox_light catppuccin_latte].each do |id|
      block = block_for(Avo.theme_manager.find(id))
      expect(block).to include("--color-navbar-background: var(--color-avo-neutral-200);")
      %w[--color-navbar-content --color-navbar-content-hover --color-navbar-control-background --color-navbar-control-content].each do |name|
        expect(block).to include("#{name}:"), "#{id} has a light navbar but does not set #{name}"
      end
    end
  end

  it "credits every editor palette" do
    editor_themes = described_class.editor_themes
    expect(editor_themes.size).to eq(13)
    notice = Avo::Engine.root.join("NOTICE").read
    editor_themes.each { |theme| expect(notice).to include(theme.title.split.first) }
  end

  it "declares only @layer base rules" do
    expect(css.scan(/^@layer (\w+)/).flatten.uniq).to eq(["base"])
  end
end
