# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "ReadonlyTakesABlock", type: :feature do
  context "new" do
    it "is readonly" do
      visit "/admin/resources/fish/new"

      expect(page).to have_field 'fish[id]', disabled: false
    end
  end

  context "edit" do
    let(:fish) { create :fish }

    it "is readonly" do
      visit "/admin/resources/fish/#{fish.id}/edit"

      expect(page).to have_field 'fish[id]', disabled: true
    end
  end
end
