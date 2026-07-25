require "rails_helper"

# Unit 4 / A10: section headings truncate like links. The default dummy sidebar
# only renders the non-collapsable heading (covered in the browser by
# spec/system/avo/group_1/sidebar_spec.rb); these component specs lock the
# markup contract for both branches, including the collapsable one whose chevron
# must stay visible (via `.sidebar-section__icon { flex-shrink: 0 }`).
RSpec.describe Avo::Sidebar::HeadingComponent, type: :component do
  let(:title) { "A Very Long Section Heading" }

  it "wraps a non-collapsable heading title in a truncating span with a `title`" do
    render_inline(described_class.new(title: title))

    label = page.find(".sidebar-section__header .sidebar-section__title")
    expect(label.text).to eq(title)
    expect(label[:title]).to eq(title)
  end

  it "wraps a collapsable heading title in a truncating span and keeps the chevron" do
    render_inline(described_class.new(title: title, collapsable: true))

    label = page.find("button.sidebar-section__header .sidebar-section__header-inner .sidebar-section__title")
    expect(label.text).to eq(title)
    expect(label[:title]).to eq(title)

    # The collapse chevron carries `sidebar-section__icon`, which the stylesheet
    # gives `flex-shrink: 0` so a long title never squashes it.
    expect(page).to have_css("button.sidebar-section__header > .sidebar-section__icon[data-menu-target='svg']", visible: :all)
  end
end
