require "rails_helper"

# `:sm` is the narrow container added alongside the Tailwind-scale rename. Its
# two numbers are both deliberate and both easy to regress silently, so they are
# pinned here rather than inferred from the stylesheet:
#
#   max-width  720px (max-w-180)  — one step below .container-md's 960px
#   clamps at  768px (md)         — deliberately far below .container-md's xl:
#                                   a late clamp would leave :sm and :md
#                                   pixel-identical on every laptop, which is
#                                   where a narrow container is most worth
#                                   asking for. The trade is that at exactly
#                                   768px the column leaves 24px a side.
RSpec.describe "container width :sm", type: :system do
  let!(:user) { create :user }
  let(:show_path) { "/admin/resources/users/#{user.slug}" }

  let(:container_max_width) { 720 }
  let(:clamps_from) { 768 }

  around do |example|
    Avo.configuration.container_width = :sm
    example.run
    Avo.configuration.container_width = nil
  end

  def visit_at(width)
    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(width, 900)
    visit show_path
    expect(page).to have_selector(".container-sm", visible: :all)
  end

  def container_width
    page.evaluate_script(
      "document.querySelector('.container-sm').getBoundingClientRect().width"
    )
  end

  it "caps at 720px on a wide viewport" do
    visit_at(1600)

    expect(container_width).to be_within(1).of(container_max_width)
  end

  it "still caps at 720px on a laptop, where .container-md would not have" do
    visit_at(1280)

    expect(container_width).to be_within(1).of(container_max_width)
  end

  it "is already clamped at its own breakpoint" do
    visit_at(clamps_from)

    # 720 of 768 — tight, and intentionally so; the alternative was a width that
    # does nothing until 1280px.
    expect(container_width).to be_within(1).of(container_max_width)
  end

  it "spans the content area below its breakpoint" do
    visit_at(clamps_from - 1)

    expect(container_width).to be > container_max_width
  end
end
