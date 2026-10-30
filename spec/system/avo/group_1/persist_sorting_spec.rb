require "rails_helper"

# With `config.persistence` on, the sort a user picks from a table header comes back on every visit, until
# they reset it. The reset link carries no sort params, so it needs its own signal not to look like a visit.
RSpec.describe "Persist sorting", type: :system do
  let!(:alpha) { create :project, name: "Alpha" }
  let!(:zed) { create :project, name: "Zed" }

  let(:url) { "/admin/resources/projects" }

  def first_row_name
    first("tr[data-record-id] td[data-field-id='name']").text
  end

  def sort_name_ascending
    first('svg[data-tippy-content="Sort descending"]').click
    first('svg[data-tippy-content="Sort ascending"]').click
    expect(page).to have_current_path(/sort_direction=asc/)
  end

  context "with session persistence" do
    around do |example|
      Avo.configuration.persistence = {driver: :session}
      example.run
    ensure
      Avo.configuration.persistence = {driver: nil}
    end

    it "brings the picked sort back on a plain visit until it is reset" do
      visit url
      expect(first_row_name).to eq "Zed"

      sort_name_ascending
      expect(first_row_name).to eq "Alpha"

      visit url
      expect(first_row_name).to eq "Alpha"
      expect(page).to have_css 'svg[data-tippy-content="Reset sorting"]'

      first('svg[data-tippy-content="Reset sorting"]').click
      expect(page).to have_current_path(/reset_sorting/)
      expect(first_row_name).to eq "Zed"

      visit url
      expect(first_row_name).to eq "Zed"
      expect(page).not_to have_css 'svg[data-tippy-content="Reset sorting"]'
    end
  end

  context "with session persistence but sorting turned off" do
    around do |example|
      Avo.configuration.persistence = {driver: :session, sorting: false}
      example.run
    ensure
      Avo.configuration.persistence = {driver: nil}
    end

    it "forgets the picked sort on a plain visit" do
      visit url
      sort_name_ascending
      expect(first_row_name).to eq "Alpha"

      visit url
      expect(first_row_name).to eq "Zed"
    end
  end
end
