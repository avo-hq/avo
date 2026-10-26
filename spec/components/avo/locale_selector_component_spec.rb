require "rails_helper"

RSpec.describe Avo::LocaleSelectorComponent, type: :component do
  around do |example|
    original = Avo.configuration.locale_selector
    example.run
  ensure
    Avo.configuration.locale_selector = original
  end

  def render_selector(**args)
    with_controller_class Avo::BaseController do
      render_inline(described_class.new(**args))
    end
  end

  it "lists the locales Avo ships translations for by default" do
    render_selector

    expect(page).to have_css(".locale-selector__item", text: "English", visible: :all)
    expect(page).to have_css(".locale-selector__item", text: "Română", visible: :all)
    expect(page).to have_css(".locale-selector__item", text: "日本語", visible: :all)
    expect(page).to have_css(".locale-selector__item", text: "Português (Brasil)", visible: :all)
  end

  it "limits the list to the configured array" do
    Avo.configuration.locale_selector = [:en, :ro, :de]

    render_selector

    expect(page).to have_css(".locale-selector__item", count: 3, visible: :all)
    expect(page).not_to have_css(".locale-selector__item", text: "Français", visible: :all)
  end

  it "marks the current locale" do
    I18n.with_locale(:ro) { render_selector(locales: %w[en ro]) }

    expect(page).to have_css(".locale-selector__trigger[aria-label$=': Română']", text: "RO")
    expect(page).to have_css(".locale-selector__item[aria-current='true']", text: "Română", visible: :all)
    expect(page).not_to have_css(".locale-selector__item[aria-current='true']", text: "English", visible: :all)
  end

  it "offers a filter input only for long lists" do
    render_selector(locales: %w[en ro])
    expect(page).not_to have_css("input[type='search']", visible: :all)

    render_selector(locales: %w[en ro de fr it ja nl pl es])
    expect(page).to have_css("input[type='search']", visible: :all)
  end

  it "posts each choice to the locale endpoint without Turbo" do
    render_selector(locales: %w[en ro])

    expect(page).to have_css("form[action='/admin/locale'][data-turbo='false'] input[name='locale'][value='ro']", visible: :all)
    expect(page).to have_css("form[action='/admin/locale'] input[name='_method'][value='patch']", visible: :all)
  end

  it "renders nothing when fewer than two locales are available" do
    render_selector(locales: %w[en])

    expect(page).not_to have_css(".locale-selector", visible: :all)
  end

  it "renders nothing when the selector is disabled" do
    Avo.configuration.locale_selector = false

    render_selector

    expect(page).not_to have_css(".locale-selector", visible: :all)
  end
end

RSpec.describe Avo::Locales do
  it "labels a locale with its autonym" do
    expect(described_class.name_for(:de)).to eq "Deutsch"
    expect(described_class.name_for("pt-BR")).to eq "Português (Brasil)"
  end

  it "falls back to the upcased code for an unknown locale" do
    expect(described_class.name_for(:xx)).to eq "XX"
  end

  it "detects locales that ship Avo translations, ignoring fallbacks" do
    expect(described_class.translated?(:ro)).to be true
    expect(described_class.translated?(:az)).to be false
  end
end
