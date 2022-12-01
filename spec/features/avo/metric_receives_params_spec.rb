require 'rails_helper'

RSpec.feature "MetricReceivesParams", type: :feature do
  it "returns the current_user id" do
    visit "/admin/dashboards/dashy/cards/dashy.metric_from_param?index=10"

    within find(".text-5xl") do
      expect(page).to have_text admin.id
    end
  end

  it "returns the param" do
    visit "/admin/dashboards/dashy/cards/dashy.metric_from_param?index=10&metric=333"

    within find(".text-5xl") do
      expect(page).to have_text "333"
    end
  end
end
