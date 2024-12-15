require "rails_helper"

RSpec.describe "CmdReturnToSubmits", type: :system do
  let(:admin) { create :user, roles: {admin: true} }
  let(:project) { create :project }
  before do
    login_as admin
  end  # include TestHelpers::DisableAuthentication

  it "submits form when cmd+enter is pressed" do
    visit "/admin/resources/projects/#{project.id}/edit"
    element = find("input[name='project[name]']")
    element.send_keys [:control, :enter]
    expect(page).to have_text "Project updated"
  end
end
