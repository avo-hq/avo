require "rails_helper"

# A tab's `badge:` is one component instance, built once when the resource's
# fields are evaluated. The tab group renders a copy of the tab bar inside every
# panel, so that single instance is asked to render once per tab. ViewComponent
# 4.15+ refuses to render an instance twice (ReusedInstanceError,
# GHSA-8qw7-6phv-7q6p), so the group has to render the badge once and share the
# result across the copies. The dummy User resource's first tabs group carries
# `badge: Avo::UI::CountComponent.new(count: 3)` on its "Created at" tab.
RSpec.describe "Tab badges", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  def badge_pills
    response.body.scan(/class="count[^"]*"[^>]*>\s*3\s*</)
  end

  it "renders a component-instance badge on every copy of the tab bar on new" do
    get "/admin/resources/users/new"

    expect(response).to have_http_status(:ok)
    expect(badge_pills.size).to be > 1
  end

  it "renders a component-instance badge on every copy of the tab bar on show" do
    get "/admin/resources/users/#{admin_user.slug}"

    expect(response).to have_http_status(:ok)
    expect(badge_pills.size).to be > 1
  end
end
