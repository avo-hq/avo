require 'rails_helper'

RSpec.describe "Ordering", type: :feature do
  let!(:course) { create :course }
  let!(:links) { create_list :course_link, 4, course: course }
  let(:default_order) { links.map(&:id) }

  describe "order higher" do
    let(:direction) { :higher }

    it "moves an item higher" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.last.id, direction).click
      wait_for_loaded

      new_links = [links[0], links[1], links[3], links[2]]

      expect(order).to eq new_links.pluck(:id)

      order_button(new_links.third.id, direction).click
      wait_for_loaded

      expect(order).to eq [links[0], links[3], links[1], links[2]].pluck(:id)
    end

    it "doesn't move the first item higher" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.first.id, direction).click
      wait_for_loaded

      expect(order).to eq default_order
    end
  end

  describe "order lower" do
    let(:direction) { :lower }

    it "moves an item lower" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.first.id, direction).click
      wait_for_loaded

      new_links = [links[1], links[0], links[2], links[3]]

      expect(order).to eq new_links.pluck(:id)

      order_button(new_links.second.id, direction).click
      wait_for_loaded

      expect(order).to eq [links[1], links[2], links[0], links[3]].pluck(:id)
    end

    it "doesn't move the last item lower" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.last.id, direction).click
      wait_for_loaded

      expect(order).to eq default_order
    end
  end

  describe "order to_top" do
    let(:direction) { :to_top }

    it "moves an item to_top" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.last.id, direction).click
      wait_for_loaded

      new_links = [links[3], links[0], links[1], links[2]]

      expect(order).to eq new_links.pluck(:id)

      order_button(new_links.last.id, direction).click
      wait_for_loaded

      expect(order).to eq [links[2], links[3], links[0], links[1]].pluck(:id)
    end

    it "doesn't move the first item to_top" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.first.id, direction).click
      wait_for_loaded

      expect(order).to eq default_order
    end
  end

  describe "order to_bottom" do
    let(:direction) { :to_bottom }

    it "moves an item to_bottom" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.first.id, direction).click
      wait_for_loaded

      new_links = [links[1], links[2], links[3], links[0]]

      expect(order).to eq new_links.pluck(:id)

      order_button(new_links.second.id, direction).click
      wait_for_loaded

      expect(order).to eq [links[1], links[3], links[0], links[2]].pluck(:id)
    end

    it "doesn't move the last item to_bottom" do
      visit "/admin/resources/course_links"

      expect(order).to eq default_order

      order_button(links.last.id, direction).click
      wait_for_loaded

      expect(order).to eq default_order
    end
  end
end

def order
  find_all("tr td[data-field-id='id']").map(&:text).map(&:to_i)
end

def order_button(resource_id, direction)
  find("tr[data-resource-id='#{resource_id}'] [data-target='order:#{direction}']")
end
