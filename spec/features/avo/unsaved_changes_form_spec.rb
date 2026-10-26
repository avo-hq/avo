require "rails_helper"

RSpec.describe "Unsaved changes form", type: :feature do
  let!(:team) { create :team }

  around do |example|
    original = Avo.configuration.warn_on_unsaved_changes
    Avo.configuration.warn_on_unsaved_changes = true
    example.run
  ensure
    Avo.configuration.warn_on_unsaved_changes = original
  end

  it "warns on the edit form" do
    visit "/admin/resources/teams/#{team.id}/edit"

    expect(page).to have_css("form[data-controller~='unsaved-changes'][data-unsaved-changes-message-value]")
  end

  it "warns on the new form" do
    visit "/admin/resources/teams/new"

    expect(page).to have_css("form[data-controller~='unsaved-changes'][data-unsaved-changes-message-value]")
  end

  it "does not warn on a form shown in a modal" do
    visit "/admin/resources/teams/new?via_belongs_to_resource_class=Avo::Resources::TeamMembership"

    expect(page).to have_css("form[data-controller~='form']")
    expect(page).not_to have_css("form[data-controller~='unsaved-changes']")
  end

  it "does not warn when the option is off" do
    Avo.configuration.warn_on_unsaved_changes = false
    visit "/admin/resources/teams/#{team.id}/edit"

    expect(page).to have_css("form[data-controller~='form']")
    expect(page).not_to have_css("form[data-controller~='unsaved-changes']")
  end
end
