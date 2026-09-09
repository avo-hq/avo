require "rails_helper"

# The copy-to-clipboard icon has to share a line with the value it copies.
# Date-ish fields wrap their value in an element of their own so the
# `date-field` controller can rewrite it, and a block-level wrapper eats the
# whole cell width, pushing the icon onto the next line (AVO-1776).
RSpec.describe "Copyable date fields", type: :system do
  let!(:comment) { create :comment, posted_at: Time.utc(2022, 10, 2, 16, 30) }
  let!(:course) { create :course, starting_at: Time.utc(2022, 10, 2, 16, 30) }

  after do
    Avo::Resources::Comment.restore_items_from_backup
    Avo::Resources::Course.restore_items_from_backup
  end

  # The icon is beside the value when it starts after the value ends and the two
  # share a vertical center. A block-level value fills the cell instead, so the
  # icon starts at the same left edge one line down — which the horizontal
  # comparison catches and a bare overlap check does not.
  def clipboard_beside_value?(scope_selector)
    page.evaluate_script(<<~JS)
      (() => {
        const scope = document.querySelector("#{scope_selector}")
        const v = scope.querySelector('[data-controller="date-field"]').getBoundingClientRect()
        const c = scope.querySelector('[data-controller="clipboard"]').getBoundingClientRect()

        return c.left >= v.right - 1 && Math.abs((c.top + c.bottom) - (v.top + v.bottom)) <= 8
      })()
    JS
  end

  describe "date_time field" do
    before do
      Avo::Resources::Comment.with_temporary_items do
        field :id, as: :id
        field :posted_at, as: :date_time, copyable: true
      end
    end

    it "renders the copy icon next to the value on index" do
      visit "/admin/resources/comments"

      expect(field_element_by_resource_id("posted_at", comment.to_param)).to be_present
      expect(clipboard_beside_value?("[data-resource-id='#{comment.to_param}'] [data-field-id='posted_at']")).to be true
    end

    it "renders the copy icon next to the value on show" do
      visit "/admin/resources/comments/#{comment.id}"

      expect(field_wrapper("posted_at")).to be_present
      expect(clipboard_beside_value?("[data-field-id='posted_at']")).to be true
    end
  end

  describe "time field" do
    before do
      Avo::Resources::Course.with_temporary_items do
        field :id, as: :id
        field :starting_at, as: :time, copyable: true
      end
    end

    it "renders the copy icon next to the value on index" do
      visit "/admin/resources/courses"

      expect(field_element_by_resource_id("starting_at", course.to_param)).to be_present
      expect(clipboard_beside_value?("[data-resource-id='#{course.to_param}'] [data-field-id='starting_at']")).to be true
    end
  end
end
