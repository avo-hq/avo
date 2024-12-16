require "rails_helper"

RSpec.describe "CmdReturnToSubmits", type: :system do
  let(:project) { create :project }

  it "submits form when cmd+enter is pressed" do
    visit "/admin/resources/projects/#{project.id}/edit"
    find("input[name='project[name]']").send_keys [:control, :enter]
    expect(page).to have_text "Project was successfully updated"
  end
end
