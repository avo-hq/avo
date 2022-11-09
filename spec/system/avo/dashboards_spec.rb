require "rails_helper"

RSpec.describe "Dashboards", type: :system do
  let(:dashboard_id) { "dashy" }
  let(:full_card_id) { "#{dashboard_id}_#{card_id}" }

  describe "empty dashboard" do
    it "shows the empty screen" do
      visit "/admin/dashboards/sales"

      content = page.find(".content")
      expect(content).to have_text "Sales"
      expect(content).to have_text "Tiny dashboard description"
      expect(content).to have_text "No cards present"
      expect(content).to have_css "[data-target='table-empty-state-svg']"

      expect(page).to have_title "Sales — Avocadelicious"
    end
  end

  describe "dashboard with cards" do
    let(:card) { page.find("turbo-frame[id='#{full_card_id}']") }
    let(:wait_for_card) { wait_for_turbo_frame_id full_card_id }

    subject do
      visit "/admin/dashboards/dashy"

      wait_for_card

      card
    end

    it "shows the dashboard info" do
      visit "/admin/dashboards/dashy"

      content = page.find(".content")
      expect(content).to have_text "Dashy"
      expect(content).to have_text "The first dashbaord"
      expect(content).not_to have_text "No cards present"
      expect(content).not_to have_css "[data-target='table-empty-state-svg']"

      expect(page).to have_title "Dashy — Avocadelicious"
    end

    describe "metric card" do
      let!(:users) { create_list :user, 10 }
      let!(:initial_user) { create :user, created_at: 1.year.ago }

      let(:index) { 0 }
      let(:card_id) { "users_metric" }

      let(:card) { page.find("turbo-frame[id='#{full_card_id}'][data-card-index='#{index}']") }

      it do
        is_expected.to have_text "Users count"
        is_expected.to have_text "11"
        description_tooltip_has_text "Users description"
      end

      it "changes displays different data when changing the range" do
        subject

        select "ALL", from: "#{card_id}_#{index}_range"
        expect(card).to have_text "12"
      end
    end

    describe "metric card with options" do
      let!(:users) { create_list :user, 10, active: false }
      let!(:active_users) { create_list :user, 3, active: true }
      let!(:initial_user) { create :user, created_at: 1.year.ago }

      let(:index) { 3 }
      let(:card_id) { "users_metric" }

      let(:card) { page.find("turbo-frame[id='#{full_card_id}'][data-card-index='#{index}']") }

      it do
        is_expected.to have_text "Active users metric"
        is_expected.to have_text "3"
        description_tooltip_has_text "Count of the active users."
      end
    end

    describe "prefix metric card" do
      let(:card_id) { "amount_raised" }

      it do
        is_expected.to have_text "Amount raised"
        is_expected.to have_text "$\n9001" # test prefix and suffix. 10 new users + admin
      end
    end

    describe "suffix metric card" do
      let(:card_id) { "percent_done" }

      it do
        is_expected.to have_text "Percent done"
        is_expected.to have_text "42\n%" # test prefix and suffix. 10 new users + admin
        description_tooltip_has_text "This is the progress we made so far..."
      end
    end

    describe "custom partial card" do
      let(:card_id) { "users_custom_card" }

      it do
        is_expected.to have_text "Users custom card"
        is_expected.to have_text "Dashboard ID: Dashy"
        is_expected.to have_text "Current user ID: #{admin.id}"
        description_tooltip_has_text "This card has been loaded from a custom partial and has access to the options hash and the dashboard params."
      end
    end

    describe "custom map card" do
      let(:card_id) { "map_card" }

      it do
        is_expected.not_to have_text "Map card"
        is_expected.to have_css "iframe[loading='lazy']"
      end
    end

    describe "chartkick area card" do
      let(:card_id) { "user_signups" }

      it do
        is_expected.to have_text "User signups"
        is_expected.to have_css "canvas"
      end
    end

    describe "chartkick scatter card" do
      let(:card_id) { "scatter" }

      it do
        is_expected.to have_text "Scatter"
        is_expected.to have_css "canvas"
      end
    end

    describe "chartkick line card" do
      let(:card_id) { "line_chart" }

      it do
        is_expected.to have_text "Line chart"
        is_expected.to have_css "canvas"
      end
    end

    describe "chartkick column card" do
      let(:card_id) { "example_column_chart" }

      it do
        is_expected.to have_text "Example column chart"
        is_expected.to have_css "canvas"
      end
    end

    describe "chartkick bar card" do
      let(:card_id) { "example_bar_chart" }

      it do
        is_expected.to have_text "Example bar chart"
        is_expected.to have_css "canvas"
      end
    end

    describe "chartkick bar card" do
      let(:card_id) { "example_bar_chart" }

      it do
        is_expected.to have_text "Example bar chart"
        is_expected.to have_css "canvas"
      end
    end
  end

  describe "card options" do
    let(:url) { "/admin/dashboards/dashy" }

    subject {
      visit url
      page
    }

    it { is_expected.to have_text "Users count" }
    it { is_expected.to have_text "Active users metric" }
  end
end

RSpec.describe "Dashboards", type: :feature do
  describe "dashboards visibility" do
    subject {
      visit url
      page
    }

    describe "visible dashboard" do
      let(:url) { "/admin/dashboards/dashy" }

      it { is_expected.to have_text "The first dashbaord" }
    end

    describe "hidden dashboard" do
      let(:url) { "/admin/dashboards/hidden_dash" }

      it "returns 404" do
        expect {
          visit url
        }.to raise_error ActionController::RoutingError
      end
    end
  end
end

def description_tooltip_has_text(text = "")
  subject

  card.find("[data-target='card-description']").hover

  expect(page.find(".tippy-content[data-state='visible']")).to have_text text
end
