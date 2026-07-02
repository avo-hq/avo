require "rails_helper"

RSpec.describe Avo::Fields::CheckboxListField::ItemComponent, type: :component do
  it "renders an unchecked checkbox row" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      name: "bundle[addon_ids][]",
      checked: false,
      input_html_id: "bundle_addon_ids_1"
    ))

    expect(page).to have_css("label.checkbox-list__row")
    expect(page).to have_css("label[data-checkbox-list-field-target='row'][data-checkbox-list-field-search-text='Premium']")
    expect(page).to have_css("input[type='checkbox'][id='bundle_addon_ids_1'][name='bundle[addon_ids][]'][value='1']")
    expect(page).not_to have_css("input[checked]")
    expect(page).to have_text "Premium"
  end

  it "renders a checked checkbox row" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      name: "bundle[addon_ids][]",
      checked: true
    ))

    expect(page).to have_css("input[type='checkbox'][checked]")
  end

  it "escapes title content" do
    render_inline(described_class.new(
      id: "1",
      title: "<script>alert('x')</script>",
      name: "bundle[addon_ids][]"
    ))

    expect(page).not_to have_css "script"
    expect(page).to have_text "<script>alert('x')</script>"
  end

  it "renders avatar and description content" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      image_url: "/avatar.png",
      image_format: "rounded",
      image_alt: "Premium avatar",
      description: "Best for larger teams",
      name: "bundle[addon_ids][]"
    ))

    expect(page).to have_css("img.search-item-image.rounded-sm[src='/avatar.png'][alt='Premium avatar']")
    expect(page).to have_css(".search-item-body")
    expect(page).to have_css(".search-item-title", text: "Premium")
    expect(page).to have_css(".search-item-description", text: "Best for larger teams")
    expect(page).to have_css("label[data-checkbox-list-field-search-text='Premium Best for larger teams']")
  end

  it "defaults unknown image formats to circle" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      image_url: "/avatar.png",
      image_format: "hexagon",
      name: "bundle[addon_ids][]"
    ))

    expect(page).to have_css("img.search-item-image.rounded-full[alt='Premium']")
    expect(page).not_to have_css("img.rounded-hexagon")
  end

  it "escapes description content" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      description: "<script>alert('x')</script>",
      name: "bundle[addon_ids][]"
    ))

    expect(page).not_to have_css "script"
    expect(page).to have_text "<script>alert('x')</script>"
  end

  it "renders the given input name without changing bracket grammar" do
    render_inline(described_class.new(
      id: "1",
      title: "Premium",
      name: "nested[bundle][addon_ids][]"
    ))

    expect(page).to have_css("input[name='nested[bundle][addon_ids][]']")
  end
end
